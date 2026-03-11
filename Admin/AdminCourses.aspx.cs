using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Admin
{
    public partial class AdminCourses : System.Web.UI.Page
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                MainMultiView.ActiveViewIndex = 0;
                BindSummaryStats();
                BindArticleCards();
            }
        }

        private void BindSummaryStats()
        {
            lblTotalArticles.Text = ExecScalar("SELECT COUNT(*) FROM Articles").ToString();
            lblTotalCompletions.Text = ExecScalar("SELECT COUNT(*) FROM CourseProgress").ToString();
            lblTotalMembers.Text = ExecScalar("SELECT COUNT(*) FROM Users WHERE Role = 'Member'").ToString();
        }

        // FIX: Completions sub-query now uses up.ArticleID = a.ArticleID (per-article tracking)
        private void BindArticleCards()
        {
            string sql = @"
                SELECT
                    a.ArticleID,
                    a.Title,
                    ISNULL(a.ImageURL, 'fa-book') AS ImageURL,
                    ISNULL(a.Views,    0)         AS Views,
                    c.CategoryName,
                    
                    -- UPDATED: Now counts from CourseProgress (cp) instead of UserProgress!
                    (SELECT COUNT(DISTINCT cp.UserID)
                     FROM CourseProgress cp
                     WHERE cp.ArticleID = a.ArticleID) AS Completions,
                     
                    (SELECT COUNT(*) FROM Users WHERE Role = 'Member') AS TotalMembers,
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

            dt.Columns.Add("CompletionRate", typeof(int));
            foreach (DataRow row in dt.Rows)
            {
                int total = Convert.ToInt32(row["TotalMembers"]);
                int done = Convert.ToInt32(row["Completions"]);
                row["CompletionRate"] = total > 0 ? (done * 100 / total) : 0;
            }

            DataView dvML = new DataView(dt); dvML.RowFilter = "CategoryName = 'Machine Learning'";
            DataView dvRobot = new DataView(dt); dvRobot.RowFilter = "CategoryName = 'Robotics'";

            rptML.DataSource = dvML; rptML.DataBind();
            rptRobot.DataSource = dvRobot; rptRobot.DataBind();
        }

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ViewArticle") return;
            LoadAnalytics(Convert.ToInt32(e.CommandArgument));
        }

        // FIX: All analytics queries now use ArticleID for per-article accuracy
        private void LoadAnalytics(int articleID)
        {
            string sqlArt = @"
                SELECT a.Title,
                       ISNULL(a.Views, 0) AS Views,
                       c.CategoryName, c.CategoryID
                FROM Articles a
                INNER JOIN Categories c ON a.CategoryID = c.CategoryID
                WHERE a.ArticleID = @id";

            string title = "", catName = "";
            int views = 0, catID = 0;

            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sqlArt, conn))
            {
                cmd.Parameters.AddWithValue("@id", articleID);
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) return;
                    title = dr["Title"].ToString();
                    views = Convert.ToInt32(dr["Views"]);
                    catName = dr["CategoryName"].ToString();
                    catID = Convert.ToInt32(dr["CategoryID"]);
                }
            }

            // FIX: Count completions per-article
            int completions = Convert.ToInt32(ExecScalarParam(
                "SELECT COUNT(DISTINCT UserID) FROM CourseProgress WHERE ArticleID = @id",
                "@id", articleID));

            int totalMembers = Convert.ToInt32(ExecScalar(
                "SELECT COUNT(*) FROM Users WHERE Role = 'Member'"));

            int rate = totalMembers > 0 ? (completions * 100 / totalMembers) : 0;

            int qCount = Convert.ToInt32(ExecScalarParam(
                @"SELECT COUNT(*) FROM Questions qn
                  INNER JOIN Quizzes qz ON qn.QuizID = qz.QuizID
                  WHERE qz.CategoryID = @cid",
                "@cid", catID));

            lblAnalyticsTitle.Text = title;
            lblCategory.Text = catName;
            lblTotalViews.Text = views.ToString();
            lblStudentCompletions.Text = completions.ToString();
            lblCompletionRate.Text = rate.ToString();
            lblQCount.Text = qCount.ToString();

            // FIX: Who-completed table queries by ArticleID
            string sqlWho = @"
                SELECT u.Username, u.FirstName, u.LastName,
                       ISNULL(CONVERT(NVARCHAR, cp.CompletedDate, 103), '') AS CompletedDate
                FROM CourseProgress cp
                INNER JOIN Users u ON cp.UserID = u.UserID
                WHERE cp.ArticleID = @id
                ORDER BY cp.CompletedDate DESC";

            DataTable dtWho = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlDataAdapter da = new SqlDataAdapter(sqlWho, conn))
            {
                da.SelectCommand.Parameters.AddWithValue("@id", articleID);
                da.Fill(dtWho);
            }

            litCompletions.Text = BuildCompletionsTable(dtWho);
            MainMultiView.ActiveViewIndex = 1;
        }

        private string BuildCompletionsTable(DataTable dt)
        {
            if (dt.Rows.Count == 0)
            {
                return "<div class='no-data'><i class='fas fa-info-circle'></i> No students have completed this module yet.</div>";
            }

            StringBuilder sb = new StringBuilder();
            sb.Append("<table class='completions-table'>");
            sb.Append("<thead><tr><th>#</th><th>Username</th><th>Name</th><th>Completed On</th></tr></thead>");
            sb.Append("<tbody>");

            int i = 1;
            foreach (DataRow row in dt.Rows)
            {
                string date = row["CompletedDate"].ToString();

                sb.Append("<tr>");
                sb.Append("<td>" + i + "</td>");
                sb.Append("<td><strong>" + row["Username"] + "</strong></td>");
                sb.Append("<td>" + row["FirstName"] + " " + row["LastName"] + "</td>");
                sb.Append("<td>" + date + "</td>");
                sb.Append("</tr>");
                i++;
            }

            sb.Append("</tbody></table>");
            return sb.ToString();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            MainMultiView.ActiveViewIndex = 0;
            BindSummaryStats();
            BindArticleCards();
        }

        private object ExecScalar(string sql)
        {
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                object result = cmd.ExecuteScalar();

                // Safely checks for both C# null and SQL DBNull
                if (result == null || result == DBNull.Value)
                {
                    return 0;
                }
                return result;
            }
        }

        private object ExecScalarParam(string sql, string paramName, object paramValue)
        {
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                // Safely passes DBNull to SQL if the parameter is missing
                cmd.Parameters.AddWithValue(paramName, paramValue ?? DBNull.Value);

                conn.Open();
                object result = cmd.ExecuteScalar();

                // Safely checks for both C# null and SQL DBNull
                if (result == null || result == DBNull.Value)
                {
                    return 0;
                }
                return result;
            }
        }
    }
}