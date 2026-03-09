using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Member
{
    public partial class Courses : System.Web.UI.Page
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["db"].ConnectionString;
        
        // Get current logged-in UserID from Session
        private int CurrentUserID
        {
            get
            {
                if (Session["UserID"] != null)
                    return Convert.ToInt32(Session["UserID"]);

                string[] usernameKeys = { "Username", "username", "UserName", "user", "User" };
                foreach (string key in usernameKeys)
                {
                    if (Session[key] != null)
                    {
                        using (SqlConnection c = new SqlConnection(_conn))
                        using (SqlCommand cmd = new SqlCommand("SELECT UserID FROM Users WHERE Username = @u", c))
                        {
                            cmd.Parameters.AddWithValue("@u", Session[key].ToString());
                            c.Open();
                            object r = cmd.ExecuteScalar();
                            if (r != null)
                            {
                                int id = Convert.ToInt32(r);
                                Session["UserID"] = id;
                                return id;
                            }
                        }
                    }
                }
                return 0;
            }
        }

        // ── PAGE LOAD ──────────────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                MainView.ActiveViewIndex = 0;
                BindCourseCards();
            }
        }

        // ── BIND COURSE CARDS ─────────────────────────────────────────────────
        // SELECT Articles + Categories + UserProgress from database
        private void BindCourseCards()
        {
            int uid = CurrentUserID;

            string sql = @"
                SELECT
                    a.ArticleID,
                    a.Title,
                    a.ImageURL,
                    ISNULL(a.Description, '') AS Description,
                    c.CategoryName,
                    CASE WHEN EXISTS (
                        SELECT 1 FROM UserProgress up
                        WHERE up.UserID = @uid AND up.ArticleID = a.ArticleID
                    ) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsCompleted
                FROM Articles a
                INNER JOIN Categories c ON a.CategoryID = c.CategoryID
                WHERE a.Status = 'Published'
                ORDER BY c.CategoryName, a.ArticleID";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
            {
                da.SelectCommand.Parameters.AddWithValue("@uid", uid);
                da.Fill(dt);
            }

            // Bind ML and Robotics to separate repeaters
            DataView dvML = new DataView(dt); dvML.RowFilter = "CategoryName = 'Machine Learning'";
            DataView dvRobot = new DataView(dt); dvRobot.RowFilter = "CategoryName = 'Robotics'";

            lblMLCount.Text = dvML.Count.ToString() + " modules";
            lblRobotCount.Text = dvRobot.Count.ToString() + " modules";

            rptML.DataSource = dvML; rptML.DataBind();
            rptRobot.DataSource = dvRobot; rptRobot.DataBind();
        }

        // Helper called from .aspx databinding expressions
        public bool IsCompleted(object val)
        {
            if (val == null || val == DBNull.Value) return false;
            return Convert.ToBoolean(val);
        }



        // ── OPEN COURSE — user clicks "Start Learning" or "Review" ────────────
        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "OpenCourse") return;
            int articleID = Convert.ToInt32(e.CommandArgument);
            LoadLearningRoom(articleID);
        }

        // ── LOAD LEARNING ROOM ────────────────────────────────────────────────
        // Reads one article + its quiz questions from the database
        private void LoadLearningRoom(int articleID)
        {
            ViewState["CurrentArticleID"] = articleID;

            // SELECT article using SqlCommand + SqlDataReader (Lab 6/7 pattern)
            string sqlArt = @"
                SELECT a.Title, a.Content,
                       ISNULL(a.Description, '') AS Description,
                       c.CategoryName
                FROM Articles a
                INNER JOIN Categories c ON a.CategoryID = c.CategoryID
                WHERE a.ArticleID = @id";

            string title = "";
            string content = "";
            string desc = "";
            string category = "";

            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sqlArt, conn))
            {
                cmd.Parameters.AddWithValue("@id", articleID);
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        title = dr["Title"].ToString();
                        content = dr["Content"].ToString();
                        desc = dr["Description"].ToString();
                        category = dr["CategoryName"].ToString();
                    }
                    else
                    {
                        // Article not found — return to catalogue safely
                        MainView.ActiveViewIndex = 0;
                        BindCourseCards();
                        return;
                    }
                }
            }

            // Populate UI
            lblBreadCat.Text = category;
            lblBreadTitle.Text = title;
            lblTitle.Text = title;

            bool isML = (category == "Machine Learning");
            lblCatTag.Text = string.Format(
                "<span class='art-tag {0}'>{1}</span>",
                isML ? "ml" : "robot", category);

            // Strip any embedded quiz HTML from article Content before displaying
            // (old seeded articles had quiz HTML baked into the Content field)
            int quizCutoff = content.IndexOf("<div class='quiz", System.StringComparison.OrdinalIgnoreCase);
            if (quizCutoff < 0) quizCutoff = content.IndexOf("<h2>Test Your", System.StringComparison.OrdinalIgnoreCase);
            if (quizCutoff < 0) quizCutoff = content.IndexOf("<h3>Test Your", System.StringComparison.OrdinalIgnoreCase);
            if (quizCutoff < 0) quizCutoff = content.IndexOf("Test Your Understanding", System.StringComparison.OrdinalIgnoreCase);
            if (quizCutoff < 0) quizCutoff = content.IndexOf("Knowledge Check", System.StringComparison.OrdinalIgnoreCase);
            if (quizCutoff > 0) content = content.Substring(0, quizCutoff);
            litContent.Text = content;
            litTakeaways.Text = BuildTakeaways(desc);

            // Check if already completed — update button state
            bool done = IsArticleCompleted(articleID);
            if (done)
            {
                btnMarkComplete.Text = "<i class='fas fa-check-circle'></i> Completed!";
                btnMarkComplete.CssClass = "btn-complete completed";
                btnMarkComplete.Enabled = false;
            }
            else
            {
                btnMarkComplete.Text = "<i class='fas fa-check-circle'></i> Mark as Completed";
                btnMarkComplete.CssClass = "btn-complete";
                btnMarkComplete.Enabled = true;
            }

            // Load quiz questions for this category
            litQuiz.Text = BuildQuizHTML(category);

            MainView.ActiveViewIndex = 1;
        }

        // ── BUILD TAKEAWAYS ───────────────────────────────────────────────────
        // Description in DB is stored as pipe-separated: "Point 1|Point 2|Point 3"
        private string BuildTakeaways(string desc)
        {
            if (string.IsNullOrWhiteSpace(desc))
                return "<p style='font-size:0.83rem;color:var(--text-muted)'>No takeaways listed.</p>";

            StringBuilder sb = new StringBuilder("<ul class='takeaway-list'>");
            foreach (string item in desc.Split('|'))
            {
                string t = item.Trim();
                if (!string.IsNullOrEmpty(t))
                    sb.AppendFormat("<li><i class='fas fa-check-circle'></i> {0}</li>", t);
            }
            sb.Append("</ul>");
            return sb.ToString();
        }

        // ── BUILD QUIZ HTML ───────────────────────────────────────────────────
        // SELECT from Quizzes + Questions tables using SqlDataAdapter (Lab 8 pattern)
        private string BuildQuizHTML(string categoryName)
        {
            // Find the quiz for this category
            string sqlQuiz = @"
                SELECT TOP 1 q.QuizID
                FROM Quizzes q
                INNER JOIN Categories c ON q.CategoryID = c.CategoryID
                WHERE c.CategoryName = @cat";

            int quizID = 0;
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sqlQuiz, conn))
            {
                cmd.Parameters.AddWithValue("@cat", categoryName);
                conn.Open();
                object r = cmd.ExecuteScalar(); // ExecuteScalar for single value (Lab 7)
                if (r != null) quizID = Convert.ToInt32(r);
            }

            if (quizID == 0)
                return "<div class='no-quiz'><i class='fas fa-hourglass-start'></i> No quiz available yet for this module.</div>";

            // Load questions using SqlDataAdapter + DataTable (Lab 8 pattern)
            DataTable dtQ = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlDataAdapter da = new SqlDataAdapter(
                "SELECT QuestionID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer FROM Questions WHERE QuizID = @qid ORDER BY QuestionID", conn))
            {
                da.SelectCommand.Parameters.AddWithValue("@qid", quizID);
                da.Fill(dtQ);
            }

            if (dtQ.Rows.Count == 0)
                return "<div class='no-quiz'><i class='fas fa-hourglass-start'></i> No questions added yet.</div>";

            // Build question cards — use data-correct attribute, zero JS quoting issues
            StringBuilder sb = new StringBuilder();
            int num = 1;
            foreach (DataRow row in dtQ.Rows)
            {
                int qid = Convert.ToInt32(row["QuestionID"]);
                string qtext = row["QuestionText"].ToString();
                string optA = row["OptionA"].ToString();
                string optB = row["OptionB"].ToString();
                string optC = row["OptionC"].ToString();
                string optD = row["OptionD"].ToString();
                string correct = row["CorrectAnswer"].ToString().Trim().ToUpper();

                sb.Append("<div class='quiz-q-card'>");
                sb.Append("<p class='q-text'>" + num + ". " + qtext + "</p>");
                sb.Append("<div class='q-options'>");
                sb.Append("<label><input type='radio' name='q" + qid + "' value='A'> " + optA + "</label>");
                sb.Append("<label><input type='radio' name='q" + qid + "' value='B'> " + optB + "</label>");
                sb.Append("<label><input type='radio' name='q" + qid + "' value='C'> " + optC + "</label>");
                sb.Append("<label><input type='radio' name='q" + qid + "' value='D'> " + optD + "</label>");
                sb.Append("</div>");
                // Store correct answer in data-correct attribute — no JS quote escaping needed
                sb.Append("<button type='button' class='btn-check' data-qid='" + qid + "' data-correct='" + correct + "' onclick='checkAnswer(this)'>Check Answer</button>");
                sb.Append("<div class='q-feedback' id='fb" + qid + "'></div>");
                sb.Append("</div>");
                num++;
            }
            return sb.ToString();
        }

        // ── CHECK IF COMPLETED ────────────────────────────────────────────────
        // SELECT COUNT with ExecuteScalar (Lab 7 pattern)
        private bool IsArticleCompleted(int articleID)
        {
            int uid = CurrentUserID;
            if (uid == 0) return false;

            string sql = @"
                SELECT COUNT(1)
                FROM UserProgress
                WHERE UserID = @uid AND ArticleID = @aid";

            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                cmd.Parameters.AddWithValue("@aid", articleID);
                conn.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        // ── MARK AS COMPLETED ─────────────────────────────────────────────────
        // INSERT into UserProgress using ExecuteNonQuery (Lab 6 pattern)
        protected void btnMarkComplete_Click(object sender, EventArgs e)
        {
            int uid = CurrentUserID;
            int articleID = Convert.ToInt32(ViewState["CurrentArticleID"]);

            if (uid == 0) { Response.Redirect("~/ZerotoAI/Login.aspx"); return; }

            // Get quiz linked to this article's category
            string sqlQuiz = @"
                SELECT TOP 1 q.QuizID
                FROM Quizzes q
                INNER JOIN Articles a ON a.CategoryID = q.CategoryID
                WHERE a.ArticleID = @aid";

            int quizID = 0;
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sqlQuiz, conn))
            {
                cmd.Parameters.AddWithValue("@aid", articleID);
                conn.Open();
                object r = cmd.ExecuteScalar();
                if (r != null) quizID = Convert.ToInt32(r);
            }

            if (quizID == 0) return;

            // INSERT only if not already completed (prevent duplicates)
            if (!IsArticleCompleted(articleID))
            {
                // Store ArticleID in UserProgress so each article is tracked individually
                string sqlInsert = @"
                    INSERT INTO UserProgress (UserID, QuizID, ArticleID, Score, CompletedDate)
                    VALUES (@uid, @qid, @aid, 0, GETDATE())";

                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sqlInsert, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    cmd.Parameters.AddWithValue("@qid", quizID);
                    cmd.Parameters.AddWithValue("@aid", articleID);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            // Update button state
            btnMarkComplete.Text = "<i class='fas fa-check-circle'></i> Completed!";
            btnMarkComplete.CssClass = "btn-complete completed";
            btnMarkComplete.Enabled = false;
        }

        // ── BACK TO CATALOGUE ─────────────────────────────────────────────────
        protected void btnBack_Click(object sender, EventArgs e)
        {
            MainView.ActiveViewIndex = 0;
            BindCourseCards();
        }
    }
}