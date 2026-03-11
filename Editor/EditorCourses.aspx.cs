using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Editor
{
    public partial class EditorCourses : System.Web.UI.Page
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        // ── PAGE LOAD ──────────────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                MainMultiView.ActiveViewIndex = 0;
                BindArticleCards();
            }
        }

        // ── BADGE CSS CLASS ────────────────────────────────────────────────────
        public string GetBadgeClass(object status)
        {
            if (status == null) return "badge-draft";
            switch (status.ToString())
            {
                case "Published": return "badge-published";
                case "Unpublished": return "badge-unpublished";
                default: return "badge-draft";
            }
        }

        // ── BIND ARTICLE CARDS ─────────────────────────────────────────────────
        private void BindArticleCards()
        {
            string sql = @"
                SELECT a.ArticleID, a.Title,
                       ISNULL(a.Description,'') AS Description,
                       ISNULL(a.ImageURL,'fa-book') AS ImageURL,
                       ISNULL(a.Status,'Draft') AS Status,
                       c.CategoryName
                FROM Articles a
                INNER JOIN Categories c ON a.CategoryID = c.CategoryID
                ORDER BY c.CategoryName, a.ArticleID";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
                da.Fill(dt);

            DataView dvML = new DataView(dt); dvML.RowFilter = "CategoryName = 'Machine Learning'";
            DataView dvRobot = new DataView(dt); dvRobot.RowFilter = "CategoryName = 'Robotics'";

            rptML.DataSource = dvML; rptML.DataBind();
            rptRobot.DataSource = dvRobot; rptRobot.DataBind();
        }

        // ── REPEATER ITEM COMMAND ─────────────────────────────────────────────
        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int articleID = Convert.ToInt32(e.CommandArgument);
            switch (e.CommandName)
            {
                case "EditArticle": OpenEditArticleForm(articleID, isNew: false); break;
                case "DeleteArticle": DeleteArticle(articleID); break;
                case "ManageQuiz": OpenManageQuiz(articleID); break;
            }
        }

        // ── OPEN EDIT ARTICLE FORM ────────────────────────────────────────────
        private void OpenEditArticleForm(int articleID, bool isNew)
        {
            lblEditMsg.Visible = false;

            if (isNew)
            {
                lblFormTitle.Text = "Add New Article";
                hfArticleID.Value = "";
                txtTitle.Text = "";
                txtDescription.Text = "";
                txtContent.Text = "";
                txtIcon.Text = "fa-book";
                ddlStatus.SelectedValue = "Draft";
                ddlCategory.SelectedIndex = 0;
            }
            else
            {
                lblFormTitle.Text = "Edit Article";
                hfArticleID.Value = articleID.ToString();

                string sql = @"
                    SELECT a.Title, a.Content,
                           ISNULL(a.Description,'') AS Description,
                           ISNULL(a.ImageURL,'') AS ImageURL,
                           ISNULL(a.Status,'Draft') AS Status,
                           c.CategoryName
                    FROM Articles a
                    INNER JOIN Categories c ON a.CategoryID = c.CategoryID
                    WHERE a.ArticleID = @id";

                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", articleID);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            txtTitle.Text = dr["Title"].ToString();
                            txtDescription.Text = dr["Description"].ToString();
                            txtContent.Text = dr["Content"].ToString();
                            txtIcon.Text = dr["ImageURL"].ToString();
                            ddlStatus.SelectedValue = dr["Status"].ToString();

                            string cat = dr["CategoryName"].ToString();
                            if (ddlCategory.Items.FindByValue(cat) != null)
                                ddlCategory.SelectedValue = cat;
                        }
                    }
                }
            }

            MainMultiView.ActiveViewIndex = 1;
        }

        // ── ADD NEW ARTICLE BUTTON ────────────────────────────────────────────
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            OpenEditArticleForm(0, isNew: true);
        }

        // ── SAVE ARTICLE ──────────────────────────────────────────────────────
        // FIX: Removed duplicate lblMessage assignment that was after the if/else block
        protected void btnSaveArticle_Click(object sender, EventArgs e)
        {
            int categoryID = GetCategoryID(ddlCategory.SelectedValue);
            int editorID = GetCurrentUserID();

            if (string.IsNullOrEmpty(hfArticleID.Value))
            {
                // INSERT new article
                string sqlInsert = @"
                    INSERT INTO Articles (Title, Content, Description, ImageURL, CategoryID, AuthorID, Status, PublishDate)
                    VALUES (@title, @content, @desc, @icon, @catID, @authorID, @status, GETDATE())";

                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sqlInsert, conn))
                {
                    cmd.Parameters.AddWithValue("@title", txtTitle.Text.Trim());
                    cmd.Parameters.AddWithValue("@content", txtContent.Text.Trim());
                    cmd.Parameters.AddWithValue("@desc", txtDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@icon", txtIcon.Text.Trim());
                    cmd.Parameters.AddWithValue("@catID", categoryID);
                    cmd.Parameters.AddWithValue("@authorID", editorID);
                    cmd.Parameters.AddWithValue("@status", ddlStatus.SelectedValue);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowDashboardMessage("Article '" + txtTitle.Text + "' was created successfully.", "alert-success");
            }
            else
            {
                // UPDATE existing article
                string sqlUpdate = @"
                    UPDATE Articles
                    SET Title       = @title,
                        Content     = @content,
                        Description = @desc,
                        ImageURL    = @icon,
                        CategoryID  = @catID,
                        Status      = @status
                    WHERE ArticleID = @id";

                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sqlUpdate, conn))
                {
                    cmd.Parameters.AddWithValue("@title", txtTitle.Text.Trim());
                    cmd.Parameters.AddWithValue("@content", txtContent.Text.Trim());
                    cmd.Parameters.AddWithValue("@desc", txtDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@icon", txtIcon.Text.Trim());
                    cmd.Parameters.AddWithValue("@catID", categoryID);
                    cmd.Parameters.AddWithValue("@status", ddlStatus.SelectedValue);
                    cmd.Parameters.AddWithValue("@id", Convert.ToInt32(hfArticleID.Value));
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowDashboardMessage("Article '" + txtTitle.Text + "' was updated successfully.", "alert-success");
            }

            // NOTE: NO duplicate assignment here — ShowDashboardMessage above handles it
            MainMultiView.ActiveViewIndex = 0;
            BindArticleCards();
        }

        // ── DELETE ARTICLE ─────────────────────────────────────────────────────
        // FIX: Delete UserProgress rows for this article FIRST (avoids FK constraint crash)
        private void DeleteArticle(int articleID)
        {
            string title = "";
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand("SELECT Title FROM Articles WHERE ArticleID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", articleID);
                conn.Open();
                object r = cmd.ExecuteScalar();
                if (r != null) title = r.ToString();
            }

            // Step 1: Remove progress rows first (prevents FK error)
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand("DELETE FROM UserProgress WHERE ArticleID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", articleID);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            // Step 2: Now safe to delete the article
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand("DELETE FROM Articles WHERE ArticleID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", articleID);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            ShowDashboardMessage("Article '" + title + "' was deleted.", "alert-danger");
            BindArticleCards();
        }

        // ── OPEN MANAGE QUIZ VIEW ──────────────────────────────────────────────
        private void OpenManageQuiz(int articleID)
        {
            lblQuizMsg.Visible = false;
            hfQuizArticleID.Value = articleID.ToString();
            hfEditQuestionID.Value = "";

            string sqlArt = @"
                SELECT a.Title, c.CategoryName, c.CategoryID
                FROM Articles a
                INNER JOIN Categories c ON a.CategoryID = c.CategoryID
                WHERE a.ArticleID = @id";

            string catName = "";
            int catID = 0;

            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sqlArt, conn))
            {
                cmd.Parameters.AddWithValue("@id", articleID);
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        lblQuizArticleTitle.Text = dr["Title"].ToString();
                        catName = dr["CategoryName"].ToString();
                        catID = Convert.ToInt32(dr["CategoryID"]);
                    }
                }
            }

            int quizID = GetOrCreateQuiz(catID, catName);
            hfQuizID.Value = quizID.ToString();

            ResetQuestionForm();
            BindQuestions(quizID);

            MainMultiView.ActiveViewIndex = 2;
        }

        // ── GET OR CREATE QUIZ ─────────────────────────────────────────────────
        private int GetOrCreateQuiz(int catID, string catName)
        {
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 QuizID FROM Quizzes WHERE CategoryID = @cid", conn))
            {
                cmd.Parameters.AddWithValue("@cid", catID);
                conn.Open();
                object r = cmd.ExecuteScalar();
                if (r != null) return Convert.ToInt32(r);
            }

            string sqlCreate = @"
                INSERT INTO Quizzes (Title, CategoryID)
                VALUES (@title, @cid);
                SELECT SCOPE_IDENTITY();";

            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sqlCreate, conn))
            {
                cmd.Parameters.AddWithValue("@title", catName + " Quiz");
                cmd.Parameters.AddWithValue("@cid", catID);
                conn.Open();
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        // ── BIND QUESTIONS ─────────────────────────────────────────────────────
        private void BindQuestions(int quizID)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlDataAdapter da = new SqlDataAdapter(
                "SELECT QuestionID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer FROM Questions WHERE QuizID = @qid ORDER BY QuestionID", conn))
            {
                da.SelectCommand.Parameters.AddWithValue("@qid", quizID);
                da.Fill(dt);
            }

            rptQuestions.DataSource = dt;
            rptQuestions.DataBind();
            lblNoQuestions.Visible = (dt.Rows.Count == 0);
        }

        // ── QUESTION REPEATER COMMAND ──────────────────────────────────────────
        protected void rptQuestions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int qid = Convert.ToInt32(e.CommandArgument);
            int quizID = Convert.ToInt32(hfQuizID.Value);

            if (e.CommandName == "DeleteQuestion")
            {
                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand("DELETE FROM Questions WHERE QuestionID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", qid);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowQuizMessage("Question deleted.", "alert-danger");
                BindQuestions(quizID);
            }
            else if (e.CommandName == "EditQuestion")
            {
                string sql = "SELECT QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer FROM Questions WHERE QuestionID = @id";
                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", qid);
                    conn.Open();
                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            hfEditQuestionID.Value = qid.ToString();
                            txtQText.Text = dr["QuestionText"].ToString();
                            txtOptA.Text = dr["OptionA"].ToString();
                            txtOptB.Text = dr["OptionB"].ToString();
                            txtOptC.Text = dr["OptionC"].ToString();
                            txtOptD.Text = dr["OptionD"].ToString();
                            ddlCorrect.SelectedValue = dr["CorrectAnswer"].ToString();
                            lblQFormTitle.Text = "Edit Question";
                            btnSaveQuestion.Text = "Update Question";
                        }
                    }
                }
            }
        }

        // ── SAVE QUESTION ──────────────────────────────────────────────────────
        protected void btnSaveQuestion_Click(object sender, EventArgs e)
        {
            int quizID = Convert.ToInt32(hfQuizID.Value);

            if (string.IsNullOrEmpty(hfEditQuestionID.Value))
            {
                string sqlInsert = @"
                    INSERT INTO Questions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer)
                    VALUES (@qid, @qtext, @a, @b, @c, @d, @correct)";

                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sqlInsert, conn))
                {
                    cmd.Parameters.AddWithValue("@qid", quizID);
                    cmd.Parameters.AddWithValue("@qtext", txtQText.Text.Trim());
                    cmd.Parameters.AddWithValue("@a", txtOptA.Text.Trim());
                    cmd.Parameters.AddWithValue("@b", txtOptB.Text.Trim());
                    cmd.Parameters.AddWithValue("@c", txtOptC.Text.Trim());
                    cmd.Parameters.AddWithValue("@d", txtOptD.Text.Trim());
                    cmd.Parameters.AddWithValue("@correct", ddlCorrect.SelectedValue);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowQuizMessage("Question added successfully.", "alert-success");
            }
            else
            {
                string sqlUpdate = @"
                    UPDATE Questions
                    SET QuestionText  = @qtext,
                        OptionA       = @a,
                        OptionB       = @b,
                        OptionC       = @c,
                        OptionD       = @d,
                        CorrectAnswer = @correct
                    WHERE QuestionID  = @id";

                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sqlUpdate, conn))
                {
                    cmd.Parameters.AddWithValue("@qtext", txtQText.Text.Trim());
                    cmd.Parameters.AddWithValue("@a", txtOptA.Text.Trim());
                    cmd.Parameters.AddWithValue("@b", txtOptB.Text.Trim());
                    cmd.Parameters.AddWithValue("@c", txtOptC.Text.Trim());
                    cmd.Parameters.AddWithValue("@d", txtOptD.Text.Trim());
                    cmd.Parameters.AddWithValue("@correct", ddlCorrect.SelectedValue);
                    cmd.Parameters.AddWithValue("@id", Convert.ToInt32(hfEditQuestionID.Value));
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowQuizMessage("Question updated successfully.", "alert-info");
            }

            ResetQuestionForm();
            BindQuestions(quizID);
        }

        // ── BACK BUTTON ───────────────────────────────────────────────────────
        protected void btnBack_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            MainMultiView.ActiveViewIndex = 0;
            BindArticleCards();
        }

        // ── UTILITIES ─────────────────────────────────────────────────────────
        private void ResetQuestionForm()
        {
            hfEditQuestionID.Value = "";
            txtQText.Text = "";
            txtOptA.Text = "";
            txtOptB.Text = "";
            txtOptC.Text = "";
            txtOptD.Text = "";
            ddlCorrect.SelectedIndex = 0;
            lblQFormTitle.Text = "Add New Question";
            btnSaveQuestion.Text = "Save Question";
        }

        private void ShowDashboardMessage(string msg, string cssClass)
        {
            lblMessage.Text = msg;
            lblMessage.CssClass = "alert-box " + cssClass;
            lblMessage.Visible = true;
        }

        private void ShowQuizMessage(string msg, string cssClass)
        {
            lblQuizMsg.Text = msg;
            lblQuizMsg.CssClass = "alert-box " + cssClass;
            lblQuizMsg.Visible = true;
        }

        private int GetCategoryID(string categoryName)
        {
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 CategoryID FROM Categories WHERE CategoryName = @n", conn))
            {
                cmd.Parameters.AddWithValue("@n", categoryName);
                conn.Open();
                object r = cmd.ExecuteScalar();
                return r != null ? Convert.ToInt32(r) : 1;
            }
        }

        // FIX: Tries all session key variations used across the project
        private int GetCurrentUserID()
        {
            if (Session["UserID"] != null) return Convert.ToInt32(Session["UserID"]);

            string[] keys = { "Username", "username", "UserName", "user", "User" };
            foreach (string key in keys)
            {
                if (Session[key] == null) continue;
                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand("SELECT UserID FROM Users WHERE Username = @u", conn))
                {
                    cmd.Parameters.AddWithValue("@u", Session[key].ToString());
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    if (r != null)
                    {
                        int id = Convert.ToInt32(r);
                        Session["UserID"] = id;
                        return id;
                    }
                }
            }
            return 1; // fallback to SystemAdmin
        }
    }
}