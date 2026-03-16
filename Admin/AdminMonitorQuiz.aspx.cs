using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI.WebControls;
using System.Net.Http;
using System.Web.Script.Serialization;
using System.Net;
using System.Net.Mail;

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

        protected async void btnGenerateReport_Click(object sender, EventArgs e)
        {
            pnlEmailDraft.Visible = false;
            lblAIReport.Text = "⏳ AI is running a deep multi-dimensional scan... Please wait.";
            lblAIReport.ForeColor = System.Drawing.Color.Blue;
            string dataContext = $"Total Questions: {lblTotalQ.Text}. Logs: {lblTotalLogs.Text}. " +
            $"Questions distribution: [{ChartLabels.Replace("'", "")}] = [{ChartData}]. " +
            $"Average Student Scores: [{StudentChartLabels.Replace("'", "")}] = [{StudentChartData}].";

            string prompt = @"You are a helpful Data Analyst. Analyze the system data and return a multi-dimensional report. Use VERY SIMPLE, easy-to-understand English. Keep sentences short. No complex corporate jargon.
            You MUST reply STRICTLY using the following HTML structure. DO NOT use markdown like ```html, just output the raw HTML directly:
            <div style='padding:12px; background:#fff0f0; border-left:6px solid #ff4757; margin-bottom:12px; border-radius:4px;'><b>🚨 Risk Detected:</b> [Point out a simple risk, e.g. low scores in a topic]</div>
            <div style='padding:12px; background:#f1fbf5; border-left:6px solid #2ed573; margin-bottom:12px; border-radius:4px;'><b>✨ Positive Trend:</b> [Highlight a simple good thing]</div>
            <div style='padding:12px; background:#f0f8ff; border-left:6px solid #1e90ff; border-radius:4px;'><b>🛠️ Actionable Plan:</b> <br/>1. [First simple tip]<br/>2. [Second simple tip]</div>
            Data: " + dataContext;

            try
            {
                string aiResponse = await GetGeminiResponse(prompt);
                lblAIReport.Text = aiResponse;
                lblAIReport.ForeColor = System.Drawing.Color.Black;
            }
            catch (Exception ex)
            {
                lblAIReport.Text = "❌ Error generating report: " + ex.Message;
                lblAIReport.ForeColor = System.Drawing.Color.Red;
            }
        }

        protected async void btnFindAtRisk_Click(object sender, EventArgs e)
        {
            lblAIReport.Text = "⏳ Scanning the database for the most struggling student...";
            lblAIReport.ForeColor = System.Drawing.Color.Orange;
            pnlEmailDraft.Visible = false;

            string worstStudent = "";
            string worstTopic = "";
            int worstScore = 100;

            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = @"SELECT TOP 1 u.Username, q.Title, up.Score FROM UserProgress up JOIN Users u ON up.UserID = u.UserID JOIN Quizzes q ON up.QuizID = q.QuizID ORDER BY up.Score ASC, up.CompletedDate DESC";
                SqlCommand cmd = new SqlCommand(sql, con);
                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                if (dr.Read())
                {
                    worstStudent = dr["Username"].ToString();
                    worstTopic = dr["Title"].ToString();
                    worstScore = Convert.ToInt32(dr["Score"]);
                }
                dr.Close();
            }

            if (string.IsNullOrEmpty(worstStudent))
            {
                lblAIReport.Text = "✅ No at-risk students found. Everyone is doing great!";
                lblAIReport.ForeColor = System.Drawing.Color.Green;
                return;
            }

            lblAIReport.Text = "";
            lblAtRiskWarning.Text = $"🎯 Target Identified: Student '{worstStudent}' recently scored a critical {worstScore}/100 in '{worstTopic}'. AI has drafted an intervention email below.";

            string prompt = $"You are a caring university academic advisor. Student '{worstStudent}' just scored {worstScore}/100 in the quiz '{worstTopic}'. " +
            $"Draft a warm, encouraging, and highly personalized email to them. Acknowledge that '{worstTopic}' can be tricky, tell them it's perfectly normal to struggle, " +
            $"and provide 2 very simple, specific study tips for '{worstTopic}'. " +
            $"Keep the tone supportive. Keep it under 120 words. Output ONLY the email content as plain text.";

            try
            {
                string emailDraft = await GetGeminiResponse(prompt);
                txtEmailDraft.Text = emailDraft.Replace("\n", "\r\n");
                pnlEmailDraft.Visible = true;
            }
            catch (Exception ex)
            {
                lblAIReport.Text = "❌ AI could not draft the email. Error: " + ex.Message;
                lblAIReport.ForeColor = System.Drawing.Color.Red;
            }
        }

        protected void btnSendEmail_Click(object sender, EventArgs e)
        {
            string recipientEmail = txtRecipientEmail.Text.Trim();
            string emailBody = txtEmailDraft.Text;
            if (string.IsNullOrEmpty(recipientEmail))
            {
                lblAIReport.Text = "❌ Please enter a recipient email address!";
                lblAIReport.ForeColor = System.Drawing.Color.Red;
                return;
            }
            try
            {
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress("kaemonng1017@gmail.com", "Zero to AI - Academic Support");
                mail.To.Add(recipientEmail);
                mail.Subject = "Important: Study Plan & Support from Zero to AI";
                mail.Body = emailBody;

                SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587);
                smtp.EnableSsl = true;
                string emailPassword = ConfigurationManager.AppSettings["EmailAppPassword"];
                smtp.Credentials = new NetworkCredential("kaemonng1017@gmail.com", emailPassword);
                smtp.Send(mail);

                pnlEmailDraft.Visible = false;
                lblAIReport.Text = $"✅ REAL Email successfully sent to {recipientEmail}!";
                lblAIReport.ForeColor = System.Drawing.Color.Green;
            }
            catch (Exception ex)
            {
                lblAIReport.Text = "❌ Failed to send email. Error: " + ex.Message;
                lblAIReport.ForeColor = System.Drawing.Color.Red;
            }
        }

        private async System.Threading.Tasks.Task<string> GetGeminiResponse(string prompt)
        {
            string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            using (HttpClient client = new HttpClient())
            {
                string url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={apiKey}";

                var requestBody = new { contents = new[] { new { parts = new[] { new { text = prompt } } } } };
                JavaScriptSerializer js = new JavaScriptSerializer();
                string jsonBody = js.Serialize(requestBody);
                StringContent content = new StringContent(jsonBody, Encoding.UTF8, "application/json");

                HttpResponseMessage response = await client.PostAsync(url, content);
                if (!response.IsSuccessStatusCode)
                {
                    string errorResponse = await response.Content.ReadAsStringAsync();
                    throw new Exception($"API Error: {response.StatusCode}. Details: {errorResponse}");
                }

                string responseString = await response.Content.ReadAsStringAsync();
                dynamic jsonResponse = js.Deserialize<dynamic>(responseString);
                return jsonResponse["candidates"][0]["content"]["parts"][0]["text"];
            }
        }
    }
}