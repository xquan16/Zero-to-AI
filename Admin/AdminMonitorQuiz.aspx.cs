using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Admin
{
    public partial class AdminMonitorQuiz : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        public string ChartLabels = "";
        public string ChartData = "";
        public string StudentChartLabels = "";
        public string StudentChartData = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            //if (Session["UserName"] == null || Session["UserRole"].ToString() != "Admin")
            //{
            //    Response.Redirect("~/Login.aspx");
            //    return;
            //}

            // 图表数据每次刷新页面都必须拿！
            LoadStats();
            LoadStudentChart();

            if (!IsPostBack)
            {
                LoadLogs();
                LoadFilterDropdown();
                LoadStudentScores();
            }
        }

        private void LoadStats()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = "SELECT q.Title, COUNT(qu.QuestionID) as QCount FROM Quizzes q LEFT JOIN Questions qu ON q.QuizID = qu.QuizID WHERE q.QuizID != 3 GROUP BY q.Title";
                SqlCommand cmd = new SqlCommand(sql, con);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                int totalQ = 0;
                StringBuilder htmlStats = new StringBuilder();

                while (dr.Read())
                {
                    string title = dr["Title"].ToString();
                    string count = dr["QCount"].ToString();

                    ChartLabels += "'" + title + "',";
                    ChartData += count + ",";
                    htmlStats.Append($"<li><span>{title}</span> <b>{count} Questions</b></li>");
                    totalQ += Convert.ToInt32(count);
                }
                dr.Close();

                ChartLabels = ChartLabels.TrimEnd(',');
                ChartData = ChartData.TrimEnd(',');
                lblTotalQ.Text = totalQ.ToString();
                litTopicStats.Text = htmlStats.ToString();
            }
        }

        private void LoadStudentChart()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // 计算每个科目的 平均分
                string sql = @"
                    SELECT q.Title, ISNULL(AVG(up.Score), 0) as AvgScore 
                    FROM Quizzes q 
                    INNER JOIN UserProgress up ON q.QuizID = up.QuizID 
                    GROUP BY q.Title";
                SqlCommand cmd = new SqlCommand(sql, con);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                StringBuilder htmlStats = new StringBuilder();
                int rowCount = 0;

                while (dr.Read())
                {
                    rowCount++;
                    string title = dr["Title"].ToString();
                    string score = dr["AvgScore"].ToString();

                    StudentChartLabels += "'" + title + "',";
                    StudentChartData += score + ",";
                    htmlStats.Append($"<li><span>{title}</span> <b>Avg: {score} Pts</b></li>");
                }
                dr.Close();

                StudentChartLabels = StudentChartLabels.TrimEnd(',');
                StudentChartData = StudentChartData.TrimEnd(',');
                litStudentChartStats.Text = htmlStats.ToString();

                // 如果没有数据，显示无数据提示
                lblNoChart2Data.Visible = (rowCount == 0);
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
                    lblLastUpdate.Text = Convert.ToDateTime(dt.Rows[0]["ActionDate"]).ToString("MMM dd, HH:mm");
                    lblNoLogs.Visible = false;
                }
                else
                {
                    lblNoLogs.Visible = true;
                }
            }
        }

        private void LoadFilterDropdown()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = "SELECT QuizID, Title FROM Quizzes";
                SqlDataAdapter da = new SqlDataAdapter(sql, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlFilterTopic.DataSource = dt;
                ddlFilterTopic.DataTextField = "Title";
                ddlFilterTopic.DataValueField = "QuizID";
                ddlFilterTopic.DataBind();
                ddlFilterTopic.Items.Insert(0, new ListItem("-- All Topics --", "0"));
            }
        }

        private void LoadStudentScores()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = "SELECT TOP 15 u.Username AS StudentName, q.Title AS QuizTitle, up.Score, up.CompletedDate FROM UserProgress up INNER JOIN Users u ON up.UserID = u.UserID INNER JOIN Quizzes q ON up.QuizID = q.QuizID";

                if (ddlFilterTopic.SelectedValue != "0" && !string.IsNullOrEmpty(ddlFilterTopic.SelectedValue))
                {
                    sql += " WHERE q.QuizID = @qid";
                }

                sql += " ORDER BY up.CompletedDate DESC";

                SqlCommand cmd = new SqlCommand(sql, con);
                if (ddlFilterTopic.SelectedValue != "0" && !string.IsNullOrEmpty(ddlFilterTopic.SelectedValue))
                {
                    cmd.Parameters.AddWithValue("@qid", ddlFilterTopic.SelectedValue);
                }

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    gvStudentScores.DataSource = dt;
                    gvStudentScores.DataBind();
                    gvStudentScores.Visible = true;
                    lblNoScores.Visible = false;
                }
                else
                {
                    gvStudentScores.Visible = false;
                    lblNoScores.Visible = true;
                }
            }
        }

        protected void ddlFilterTopic_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadStudentScores();
        }
    }
}