using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Member
{
    public partial class Courses : System.Web.UI.Page
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        // ── GET CURRENT USER ID ────────────────────────────────────────────────
        // FIX: Tries multiple session key names used across the project, caches result
        private int CurrentUserID
        {
            get
            {
                if (Session["UserID"] != null)
                    return Convert.ToInt32(Session["UserID"]);

                string[] keys = { "Username", "username", "UserName", "user", "User" };
                foreach (string key in keys)
                {
                    if (Session[key] == null) continue;
                    using (SqlConnection c = new SqlConnection(_conn))
                    using (SqlCommand cmd = new SqlCommand("SELECT UserID FROM Users WHERE Username = @u", c))
                    {
                        cmd.Parameters.AddWithValue("@u", Session[key].ToString());
                        c.Open();
                        object r = cmd.ExecuteScalar();
                        if (r != null)
                        {
                            int id = Convert.ToInt32(r);
                            Session["UserID"] = id; // cache so we only hit DB once per session
                            return id;
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
        // FIX: IsCompleted sub-query uses up.ArticleID = a.ArticleID (not CategoryID)
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
                        SELECT 1 FROM CourseProgress cp
                        WHERE cp.UserID = @uid AND cp.ArticleID = a.ArticleID
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

            DataView dvML = new DataView(dt); dvML.RowFilter = "CategoryName = 'Machine Learning'";
            DataView dvRobot = new DataView(dt); dvRobot.RowFilter = "CategoryName = 'Robotics'";

            lblMLCount.Text = dvML.Count + " modules";
            lblRobotCount.Text = dvRobot.Count + " modules";

            rptML.DataSource = dvML; rptML.DataBind();
            rptRobot.DataSource = dvRobot; rptRobot.DataBind();
        }

        // Helper used by .aspx databinding expressions
        protected bool IsCompleted(object articleIDObj)
        {
            if (articleIDObj == null) return false;
            int articleID = Convert.ToInt32(articleIDObj);
            int uid = CurrentUserID;
            if (uid <= 0) return false;

            // UPDATED: Now queries the new CourseProgress table!
            string sql = "SELECT COUNT(*) FROM CourseProgress WHERE UserID = @uid AND ArticleID = @aid";
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                cmd.Parameters.AddWithValue("@aid", articleID);
                conn.Open();
                int count = Convert.ToInt32(cmd.ExecuteScalar());
                return count > 0;
            }
        }

        // ── OPEN COURSE ───────────────────────────────────────────────────────
        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "OpenCourse") return;
            LoadLearningRoom(Convert.ToInt32(e.CommandArgument));
            ViewState["CurrentArticleID"] = Convert.ToInt32(e.CommandArgument);
        }

        // ── LOAD LEARNING ROOM ────────────────────────────────────────────────
        private void LoadLearningRoom(int articleID)
        {
            ViewState["CurrentArticleID"] = articleID;

            string sqlArt = @"
                SELECT a.Title, a.Content,
                       ISNULL(a.Description, '') AS Description,
                       c.CategoryName
                FROM Articles a
                INNER JOIN Categories c ON a.CategoryID = c.CategoryID
                WHERE a.ArticleID = @id";

            string title = "", content = "", desc = "", category = "";

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
                        MainView.ActiveViewIndex = 0;
                        BindCourseCards();
                        return;
                    }
                }
            }

            lblBreadCat.Text = category;
            lblBreadTitle.Text = title;
            lblTitle.Text = title;

            bool isML = (category == "Machine Learning");
            lblCatTag.Text = string.Format(
                "<span class='art-tag {0}'><i class='fas {1}'></i> {2}</span>",
                isML ? "ml" : "robot",
                isML ? "fa-brain" : "fa-microchip",
                category);

            // Strip any embedded quiz content from the article body
            int cut = content.IndexOf("<div class='quiz", StringComparison.OrdinalIgnoreCase);
            if (cut < 0) cut = content.IndexOf("<h2>Test Your", StringComparison.OrdinalIgnoreCase);
            if (cut < 0) cut = content.IndexOf("<h3>Test Your", StringComparison.OrdinalIgnoreCase);
            if (cut < 0) cut = content.IndexOf("Test Your Understanding", StringComparison.OrdinalIgnoreCase);
            if (cut < 0) cut = content.IndexOf("Knowledge Check", StringComparison.OrdinalIgnoreCase);
            if (cut > 0) content = content.Substring(0, cut);

            litContent.Text = content;
            litTakeaways.Text = BuildTakeaways(desc);

            // Set Mark Complete button state based on DB
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

            litQuiz.Text = BuildQuizHTML(category);
            MainView.ActiveViewIndex = 1;

            // FIX: Views counter — use ViewState flag so it fires ONCE per article visit.
            // This method is always called on PostBack, so !IsPostBack is always false here.
            string viewedKey = "Viewed_" + articleID;
            if (ViewState[viewedKey] == null)
            {
                ViewState[viewedKey] = true;
                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE Articles SET Views = ISNULL(Views, 0) + 1 WHERE ArticleID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", articleID);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // ── BUILD TAKEAWAYS ───────────────────────────────────────────────────
        // Description stored as pipe-separated: "Point 1|Point 2|Point 3"
        private string BuildTakeaways(string desc)
        {
            if (string.IsNullOrWhiteSpace(desc))
                return "<p style='font-size:.83rem;color:var(--text-muted)'>No takeaways listed.</p>";

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
        private string BuildQuizHTML(string categoryName)
        {
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
                object r = cmd.ExecuteScalar();
                if (r != null) quizID = Convert.ToInt32(r);
            }

            if (quizID == 0)
                return "<div class='no-quiz'><i class='fas fa-hourglass-start'></i> No quiz available yet for this module.</div>";

            DataTable dtQ = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlDataAdapter da = new SqlDataAdapter(
                "SELECT TOP 5 QuestionID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer FROM Questions WHERE QuizID = @qid ORDER BY NEWID()", conn))
            {
                da.SelectCommand.Parameters.AddWithValue("@qid", quizID);
                da.Fill(dtQ);
            }

            if (dtQ.Rows.Count == 0)
                return "<div class='no-quiz'><i class='fas fa-hourglass-start'></i> No questions added yet.</div>";

            StringBuilder sb = new StringBuilder();
            int num = 1;
            foreach (DataRow row in dtQ.Rows)
            {
                int qid = Convert.ToInt32(row["QuestionID"]);
                string correct = row["CorrectAnswer"].ToString().Trim().ToUpper();

                sb.Append("<div class='quiz-q'>");
                sb.Append("<div class='q-num'>Question " + num + "</div>");
                sb.Append("<div class='q-text'>" + row["QuestionText"] + "</div>");
                sb.Append("<div class='q-opts'>");

                string[] letters = { "A", "B", "C", "D" };
                string[] options = {
                    row["OptionA"].ToString(), row["OptionB"].ToString(),
                    row["OptionC"].ToString(), row["OptionD"].ToString()
                };
                for (int i = 0; i < 4; i++)
                    sb.AppendFormat(
                        "<label><input type='radio' name='q{0}' value='{1}'> <strong>{1}.</strong> {2}</label>",
                        qid, letters[i], options[i]);

                sb.Append("</div>");
                sb.AppendFormat(
                    "<button type='button' class='btn-check' data-qid='{0}' data-correct='{1}' onclick='checkAnswer(this)'>Check Answer</button>",
                    qid, correct);
                sb.Append("<div class='q-feedback' id='fb" + qid + "'></div>");
                sb.Append("</div>");
                num++;
            }
            return sb.ToString();
        }

        // ── IS ARTICLE COMPLETED ──────────────────────────────────────────────
        private bool IsArticleCompleted(int articleID)
        {
            int uid = CurrentUserID;
            if (uid == 0) return false;

            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(1) FROM CourseProgress WHERE UserID = @uid AND ArticleID = @aid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", uid);
                cmd.Parameters.AddWithValue("@aid", articleID);
                conn.Open();
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }

        // ── MARK AS COMPLETED ─────────────────────────────────────────────────
        // FIX: INSERT includes ArticleID column for per-article tracking
        protected void btnMarkComplete_Click(object sender, EventArgs e)
        {
            int uid = CurrentUserID;
            if (uid <= 0) return;

            // FIX: Use ViewState to grab the ArticleID instead of the missing HiddenField
            if (ViewState["CurrentArticleID"] == null) return;
            int articleID = Convert.ToInt32(ViewState["CurrentArticleID"]);

            // Notice: Using IsArticleCompleted to match your existing code name!
            if (!IsArticleCompleted(articleID))
            {
                // Inserts directly into the new CourseProgress table
                string sqlInsert = @"
                    INSERT INTO CourseProgress (UserID, ArticleID, CompletedDate)
                    VALUES (@uid, @aid, GETDATE())";

                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sqlInsert, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", uid);
                    cmd.Parameters.AddWithValue("@aid", articleID);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

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