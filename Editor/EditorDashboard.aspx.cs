using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Editor
{
    public partial class EditorDashboard : System.Web.UI.Page
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        private int CurrentUserID
        {
            get { return Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentUserID == 0 || Session["UserRole"] == null || Session["UserRole"].ToString() != "Editor")
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string username = Session["Username"] != null ? Session["Username"].ToString() : "Editor";
                lblWelcome.Text = "Welcome Back, " + username + "<br><br>Creator Workspace";

                LoadEditorStats();
                LoadRecentActivity(username);
            }
        }

        private void LoadEditorStats()
        {
            int publishedCount = 0;
            int totalViews = 0;
            int totalQuestions = 0;

            using (SqlConnection conn = new SqlConnection(_conn))
            {
                conn.Open();

                // 1. Count Published Articles
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Articles WHERE AuthorID = @uid AND Status = 'Published'", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", CurrentUserID);
                    publishedCount = Convert.ToInt32(cmd.ExecuteScalar() ?? 0);
                }

                // 2. Sum Total Views (Safely handling DBNull if they have 0 articles)
                using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(SUM(Views), 0) FROM Articles WHERE AuthorID = @uid", conn))
                {
                    cmd.Parameters.AddWithValue("@uid", CurrentUserID);
                    totalViews = Convert.ToInt32(cmd.ExecuteScalar() ?? 0);
                }

                // 3. Total System Questions
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Questions", conn))
                {
                    totalQuestions = Convert.ToInt32(cmd.ExecuteScalar() ?? 0);
                }
            }

            lblEdSimTotal.Text = "0"; // Placeholder for your future EditorSimulations logic!
            lblEdPublished.Text = publishedCount.ToString();
            lblEdQuestions.Text = totalQuestions.ToString();
        }

        private void LoadRecentActivity(string username)
        {
            // Pull only the 10 most recent logs for this specific Editor
            string sql = "SELECT TOP 10 ActionType, ActionDetails, ActionDate FROM ActivityLogs WHERE UserName = @un ORDER BY ActionDate DESC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@un", username);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            gvEdLogs.DataSource = dt;
            gvEdLogs.DataBind();
        }
    }
}