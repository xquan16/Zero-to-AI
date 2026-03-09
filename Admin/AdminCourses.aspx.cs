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

namespace Zero_to_AI.Admin
{
    public partial class AdminCourses : System.Web.UI.Page
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        // ── PAGE LOAD ──────────────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                MainMultiView.ActiveViewIndex = 0;
                BindSummaryStats();
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

        // ══════════════════════════════════════════════════════════════════════
        //  SUMMARY STATS — real counts from DB
        //  Proposal: "main page provides a high-level overview of system data"
        // ══════════════════════════════════════════════════════════════════════
        private void BindSummaryStats()
        {
            // Total articles
            lblTotalArticles.Text = ExecScalar(
                "SELECT COUNT(*) FROM Articles").ToString();

            // Published articles
            lblPublished.Text = ExecScalar(
                "SELECT COUNT(*) FROM Articles WHERE Status = 'Published'").ToString();

            // Total completions across all modules
            lblTotalCompletions.Text = ExecScalar(
                "SELECT COUNT(*) FROM UserProgress").ToString();

            // Registered members (Role = 'Member')
            lblTotalMembers.Text = ExecScalar(
                "SELECT COUNT(*) FROM Users WHERE Role = 'Member'").ToString();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  BIND ARTICLE CARDS
        //  Shows Views, Completions, Question count, Status per article
        //  Proposal: "view all the learning materials status" + "enrollment stats"
        // ══════════════════════════════════════════════════════════════════════
        private void BindArticleCards()
        {
            // SQL: Article info + live counts from UserProgress and Questions
            string sql = @"
                SELECT
                    a.ArticleID,
                    a.Title,
                    ISNULL(a.ImageURL, 'fa-book')  AS ImageURL,
                    ISNULL(a.Status,   'Draft')     AS Status,
                    ISNULL(a.Views,    0)           AS Views,
                    c.CategoryName,

                    -- How many students completed (have a UserProgress row for this category's quiz)
                    (SELECT COUNT(DISTINCT up.UserID)
                     FROM UserProgress up
                     INNER JOIN Quizzes q ON up.QuizID = q.QuizID
                     WHERE q.CategoryID = a.CategoryID) AS Completions,

                    -- Total registered members for completion rate denominator
                    (SELECT COUNT(*) FROM Users WHERE Role = 'Member') AS TotalMembers,

                    -- Number of quiz questions linked to this category
                    (SELECT COUNT(*)
                     FROM Questions qn
                     INNER JOIN Quizzes qz ON qn.QuizID = qz.QuizID
                     WHERE qz.CategoryID = a.CategoryID) AS QuestionCount

                FROM Articles a
                INNER JOIN Categories c ON a.CategoryID = c.CategoryID
                ORDER BY c.CategoryName, a.ArticleID";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
                da.Fill(dt);

            // Add computed CompletionRate column
            dt.Columns.Add("CompletionRate", typeof(int));
            foreach (DataRow row in dt.Rows)
            {
                int total = Convert.ToInt32(row["TotalMembers"]);
                int done = Convert.ToInt32(row["Completions"]);
                row["CompletionRate"] = total > 0 ? (done * 100 / total) : 0;
            }

            // Split into ML and Robotics repeaters
            DataView dvML = new DataView(dt); dvML.RowFilter = "CategoryName = 'Machine Learning'";
            DataView dvRobot = new DataView(dt); dvRobot.RowFilter = "CategoryName = 'Robotics'";

            rptML.DataSource = dvML; rptML.DataBind();
            rptRobot.DataSource = dvRobot; rptRobot.DataBind();
        }

        // ══════════════════════════════════════════════════════════════════════
        //  REPEATER COMMAND — View Analytics for one article
        // ══════════════════════════════════════════════════════════════════════
        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewArticle") return;
            int articleID = Convert.ToInt32(e.CommandArgument);
            LoadAnalytics(articleID);
        }

        // ══════════════════════════════════════════════════════════════════════
        //  LOAD ANALYTICS VIEW
        //  Shows real completion data per article from UserProgress
        // ══════════════════════════════════════════════════════════════════════
        private void LoadAnalytics(int articleID)
        {
            // 1. Get article info + category
            string sqlArt = @"
                SELECT a.Title, a.Status,
                       ISNULL(a.Views, 0) AS Views,
                       c.CategoryName, c.CategoryID
                FROM Articles a
                INNER JOIN Categories c ON a.CategoryID = c.CategoryID
                WHERE a.ArticleID = @id";

            string title = "";
            string status = "";
            int views = 0;
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
                        title = dr["Title"].ToString();
                        status = dr["Status"].ToString();
                        views = Convert.ToInt32(dr["Views"]);
                        catName = dr["CategoryName"].ToString();
                        catID = Convert.ToInt32(dr["CategoryID"]);
                    }
                }
            }

            if (string.IsNullOrEmpty(title)) return;

            // 2. Count students who completed (UserProgress for this category's quiz)
            int completions = Convert.ToInt32(ExecScalarParam(
                @"SELECT COUNT(DISTINCT up.UserID)
                  FROM UserProgress up
                  INNER JOIN Quizzes q ON up.QuizID = q.QuizID
                  WHERE q.CategoryID = @cid",
                "@cid", catID));

            // 3. Total members for completion rate
            int totalMembers = Convert.ToInt32(ExecScalar(
                "SELECT COUNT(*) FROM Users WHERE Role = 'Member'"));

            int rate = totalMembers > 0 ? (completions * 100 / totalMembers) : 0;

            // 4. Question count for this category
            int qCount = Convert.ToInt32(ExecScalarParam(
                @"SELECT COUNT(*) FROM Questions qn
                  INNER JOIN Quizzes qz ON qn.QuizID = qz.QuizID
                  WHERE qz.CategoryID = @cid",
                "@cid", catID));

            // 5. Populate labels
            lblAnalyticsTitle.Text = title;
            lblCategory.Text = catName;
            lblStatus.Text = "<span class='status-badge " + GetBadgeClass(status) + "'>" + status + "</span>";
            lblTotalViews.Text = views.ToString();
            lblStudentCompletions.Text = completions.ToString();
            lblCompletionRate.Text = rate.ToString();
            lblQCount.Text = qCount.ToString();

            // 6. Load who completed — SELECT from UserProgress JOIN Users
            string sqlWho = @"
                SELECT u.Username, u.FirstName, u.LastName,
                       ISNULL(CONVERT(NVARCHAR, up.CompletedDate, 103), '') AS CompletedDate,
                       ISNULL(CAST(up.Score AS NVARCHAR), '') AS Score
                FROM UserProgress up
                INNER JOIN Users u ON up.UserID = u.UserID
                INNER JOIN Quizzes q ON up.QuizID = q.QuizID
                WHERE q.CategoryID = @cid
                ORDER BY up.CompletedDate DESC";

            DataTable dtWho = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlDataAdapter da = new SqlDataAdapter(sqlWho, conn))
            {
                da.SelectCommand.Parameters.AddWithValue("@cid", catID);
                da.Fill(dtWho);
            }

            // 7. Build completions table HTML
            litCompletions.Text = BuildCompletionsTable(dtWho);

            MainMultiView.ActiveViewIndex = 1;
        }

        // ── BUILD COMPLETIONS TABLE HTML ──────────────────────────────────────
        private string BuildCompletionsTable(DataTable dt)
        {
            if (dt.Rows.Count == 0)
                return "<div class='no-data'><i class='fas fa-inbox' style='font-size:1.8rem;opacity:0.3;display:block;margin-bottom:8px'></i>No students have completed this module yet.</div>";

            StringBuilder sb = new StringBuilder();
            sb.Append("<table class='completions-table'>");
            sb.Append("<thead><tr>");
            sb.Append("<th>#</th><th>Username</th><th>Full Name</th><th>Completed On</th><th>Score</th>");
            sb.Append("</tr></thead><tbody>");

            int i = 1;
            foreach (DataRow row in dt.Rows)
            {
                string completedDate = string.IsNullOrEmpty(row["CompletedDate"].ToString()) ? "—" : row["CompletedDate"].ToString();
                string score = string.IsNullOrEmpty(row["Score"].ToString()) ? "—" : row["Score"].ToString();

                sb.Append("<tr>");
                sb.Append("<td>" + i + "</td>");
                sb.Append("<td><strong>" + row["Username"] + "</strong></td>");
                sb.Append("<td>" + row["FirstName"] + " " + row["LastName"] + "</td>");
                sb.Append("<td>" + completedDate + "</td>");
                sb.Append("<td>" + score + "</td>");
                sb.Append("</tr>");
                i++;
            }

            sb.Append("</tbody></table>");
            return sb.ToString();
        }

        // ── BACK BUTTON ───────────────────────────────────────────────────────
        protected void btnBack_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            MainMultiView.ActiveViewIndex = 0;
            BindSummaryStats();
            BindArticleCards();
        }

        // ── HELPERS — ExecuteScalar shortcuts ─────────────────────────────────
        // SELECT single value, no parameters (Lab 7 pattern)
        private object ExecScalar(string sql)
        {
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                object r = cmd.ExecuteScalar();
                return r ?? 0;
            }
        }

        // SELECT single value with one parameter
        private object ExecScalarParam(string sql, string paramName, object paramValue)
        {
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue(paramName, paramValue);
                conn.Open();
                object r = cmd.ExecuteScalar();
                return r ?? 0;
            }
        }
    }
}