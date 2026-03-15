using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using System.Net.Http;
using System.Web.Script.Serialization;
using System.Net;


namespace Zero_to_AI.Editor
{
    public partial class EditorEditQuiz : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserName"] == null || Session["UserRole"].ToString() != "Editor")
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadQuizList();
                LoadQuestions();
            }
        }

        protected async void btnGenerateAI_Click(object sender, EventArgs e)
        {
            string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];
            string topic = txtAITopic.Text.Trim();

            if (string.IsNullOrEmpty(topic))
            {
                lblAIStatus.Text = "⚠️ Please enter a topic first!";
                lblAIStatus.ForeColor = System.Drawing.Color.DarkOrange;
                return;
            }

            lblAIStatus.Text = "⏳ AI is thinking... Please wait.";
            lblAIStatus.ForeColor = System.Drawing.Color.Blue;

            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            string prompt = $"Generate one multiple-choice question about '{topic}' for university students. You MUST reply EXACTLY in this strict format without any extra markdown or JSON: QuestionText|||OptionA|||OptionB|||OptionC|||OptionD|||CorrectAnswer(must be exactly A, B, C, or D)";

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    string url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={apiKey}";
                    string jsonBody = "{\"contents\": [{\"parts\": [{\"text\": \"" + prompt.Replace("\"", "\\\"") + "\"}]}]}";
                    StringContent content = new StringContent(jsonBody, System.Text.Encoding.UTF8, "application/json");

                    HttpResponseMessage response = await client.PostAsync(url, content);
                    response.EnsureSuccessStatusCode();

                    string responseString = await response.Content.ReadAsStringAsync();

                    JavaScriptSerializer js = new JavaScriptSerializer();
                    dynamic jsonResponse = js.Deserialize<dynamic>(responseString);
                    string aiText = jsonResponse["candidates"][0]["content"]["parts"][0]["text"];

                    string[] parts = aiText.Split(new string[] { "|||" }, StringSplitOptions.None);

                    if (parts.Length >= 6)
                    {
                        txtNewQuestion.Text = parts[0].Trim();
                        txtOptA.Text = parts[1].Trim();
                        txtOptB.Text = parts[2].Trim();
                        txtOptC.Text = parts[3].Trim();
                        txtOptD.Text = parts[4].Trim();

                        string ans = parts[5].Trim().ToUpper().Replace(".", "").Replace("\n", "");
                        if (ddlCorrectAns.Items.FindByValue(ans) != null)
                        {
                            ddlCorrectAns.SelectedValue = ans;
                        }

                        lblAIStatus.Text = "✅ Question generated! You can edit it or click 'Add Question to Database'.";
                        lblAIStatus.ForeColor = System.Drawing.Color.Green;
                    }
                    else
                    {
                        lblAIStatus.Text = "⚠️ AI format error. Please click Generate again.";
                        lblAIStatus.ForeColor = System.Drawing.Color.Red;
                    }
                }
            }
            catch (Exception ex)
            {
                lblAIStatus.Text = "❌ API Error: " + ex.Message;
                lblAIStatus.ForeColor = System.Drawing.Color.Red;
            }
        }


        private void LogActivity(string action, string detail)
        {
            // Default "TestEditor" for testing
            string currentUser = "TestEditor";

            // Use the login username 
            if (Session["UserName"] != null)
            {
                currentUser = Session["UserName"].ToString();
            }

            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = "INSERT INTO ActivityLogs (UserName, ActionType, ActionDetails, ActionDate) VALUES (@user, @type, @detail, GETDATE())";
                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@user", currentUser);
                cmd.Parameters.AddWithValue("@type", action);
                cmd.Parameters.AddWithValue("@detail", detail);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void LoadQuizList()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // Only display Machine Learning and Robotics
                string sql = "SELECT QuizID, Title FROM Quizzes WHERE QuizID != 3";
                SqlDataAdapter da = new SqlDataAdapter(sql, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlQuizzes.DataSource = dt;
                ddlQuizzes.DataTextField = "Title";
                ddlQuizzes.DataValueField = "QuizID";
                ddlQuizzes.DataBind();
            }
        }

        private void LoadQuestions()
        {
            string selectedQuizId = ddlQuizzes.SelectedValue;

            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = "SELECT * FROM Questions WHERE QuizID = @qid";
                SqlDataAdapter da = new SqlDataAdapter(sql, con);
                da.SelectCommand.Parameters.AddWithValue("@qid", selectedQuizId);

                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptEditor.DataSource = dt;
                    rptEditor.DataBind();
                    rptEditor.Visible = true;
                    lblNoData.Visible = false;
                }
                else
                {
                    rptEditor.Visible = false;
                    lblNoData.Visible = true;
                }
            }
        }

        protected void ddlQuizzes_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadQuestions();
        }

        // Deletion
        protected void rptEditor_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteQuestion")
            {
                int questionIdToDelete = Convert.ToInt32(e.CommandArgument);

                using (SqlConnection con = new SqlConnection(connString))
                {
                    string sql = "DELETE FROM Questions WHERE QuestionID = @qid";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@qid", questionIdToDelete);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                // Update log, who modified
                string quizName = ddlQuizzes.SelectedItem.Text;
                LogActivity("Delete Question", $"Deleted a question from {quizName}");

                LoadQuestions();
            }
        }

        // Addtion
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (txtNewQuestion.Text.Trim() != "")
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    string sql = @"INSERT INTO Questions 
                                (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer, Marks) 
                                VALUES (@qid, @qtext, @optA, @optB, @optC, @optD, @correct, @marks)";

                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@qid", ddlQuizzes.SelectedValue);
                    cmd.Parameters.AddWithValue("@qtext", txtNewQuestion.Text);
                    cmd.Parameters.AddWithValue("@optA", txtOptA.Text);
                    cmd.Parameters.AddWithValue("@optB", txtOptB.Text);
                    cmd.Parameters.AddWithValue("@optC", txtOptC.Text);
                    cmd.Parameters.AddWithValue("@optD", txtOptD.Text);
                    cmd.Parameters.AddWithValue("@correct", ddlCorrectAns.SelectedValue);
                    cmd.Parameters.AddWithValue("@marks", txtMarks.Text);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                // Update log, who modified
                string quizName = ddlQuizzes.SelectedItem.Text;
                LogActivity("Add Question", $"Added a new question to {quizName}");

                // Clear and refresh
                txtNewQuestion.Text = ""; 
                txtOptA.Text = ""; 
                txtOptB.Text = ""; 
                txtOptC.Text = ""; 
                txtOptD.Text = ""; 
                txtAITopic.Text = ""; 
                lblAIStatus.Text = "";

                LoadQuestions();
            }
            else
            {
                lblMsg.Text = "Please enter question text.";
                lblMsg.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
}