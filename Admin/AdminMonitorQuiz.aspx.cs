using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Configuration;

namespace Zero_to_AI.Admin
{
    public partial class AdminMonitorQuiz : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        // Chart.js for Donut chart
        public string ChartLabels = "";
        public string ChartData = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            //Security Check
            if (Session["UserName"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStats();
                LoadLogs();
            }
        }

        private void LoadStats()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // Group by title exclude Mixed
                string sql = @"
                    SELECT q.Title, COUNT(qu.QuestionID) as QCount 
                    FROM Quizzes q 
                    LEFT JOIN Questions qu ON q.QuizID = qu.QuizID 
                    WHERE q.QuizID != 3 
                    GROUP BY q.Title";

                SqlCommand cmd = new SqlCommand(sql, con);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                int totalQ = 0;
                StringBuilder htmlStats = new StringBuilder(); // to generate a text list

                while (dr.Read())
                {
                    string title = dr["Title"].ToString();
                    string count = dr["QCount"].ToString();

                    // Data for Donut Chart
                    ChartLabels += "'" + title + "',";
                    ChartData += count + ",";

                    // Data for text list
                    htmlStats.Append($"<li><span>{title}</span> <b>{count} Questions</b></li>");

                    totalQ += Convert.ToInt32(dr["QCount"]);
                }
                dr.Close();

                ChartLabels = ChartLabels.TrimEnd(',');
                ChartData = ChartData.TrimEnd(',');

                // Show Data
                lblTotalQ.Text = totalQ.ToString();
                litTopicStats.Text = htmlStats.ToString(); 
            }
        }

        private void LoadLogs()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = "SELECT TOP 20 * FROM ActivityLogs ORDER BY ActionDate DESC";
                SqlDataAdapter da = new SqlDataAdapter(sql, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvLogs.DataSource = dt;
                gvLogs.DataBind();

                lblTotalLogs.Text = dt.Rows.Count.ToString();

                if (dt.Rows.Count > 0)
                {
                    // Have Log show latest
                    lblLastUpdate.Text = Convert.ToDateTime(dt.Rows[0]["ActionDate"]).ToString("MMM dd, HH:mm");
                    lblNoLogs.Visible = false;
                }
                else
                {
                    // Dont have log
                    lblNoLogs.Visible = true;
                }
            }
        }
    }
}