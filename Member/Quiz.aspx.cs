using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net.Http;
using System.Web.Script.Serialization;
using System.Net;
using System.Text;
using System.Configuration;


namespace Zero_to_AI.Member
{
    public partial class Quiz : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["ChatHistory"] == null)
            {
                Session["ChatHistory"] = "<div class='msg-bubble msg-ai'>Hi! I am your AI Tutor. Submit your quiz first, then click '💡 Ask AI to Explain' on any question!</div>";
            }

            if (!IsPostBack)
            {
                string topic = Request.QueryString["topic"];
                if (string.IsNullOrEmpty(topic)) topic = "ML";
                LoadQuestions(topic);
            }
        }

        private void LoadQuestions(string topic)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = "";

                // Just random choose 10 question due to ORDER BY NEWID()

                if (topic == "ML")
                {
                    sql = "SELECT TOP 10 * FROM Questions WHERE QuizID = 1 ORDER BY NEWID()";
                    lblTitle.Text = "🧠 Machine Learning Quiz (Random 10)";
                }
                else if (topic == "Robo")
                {
                    sql = "SELECT TOP 10 * FROM Questions WHERE QuizID = 2 ORDER BY NEWID()";
                    lblTitle.Text = "🤖 Robotics Challenge (Random 10)";
                }
                else if (topic == "All")
                {
                    sql = "SELECT TOP 10 * FROM Questions WHERE QuizID IN (1, 2) ORDER BY NEWID()";
                    lblTitle.Text = "🔥 Ultimate Mixed Challenge (Random 10)";
                }

                SqlDataAdapter da = new SqlDataAdapter(sql, con);
                DataTable dt = new DataTable();

                try
                {
                    con.Open();
                    da.Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        lblResult.Text = "No questions found for this topic!";
                        lblResult.Visible = true;
                        btnSubmit.Visible = false;
                        timerContainer.Visible = false;
                        btnBack.Visible = true;
                    }
                    // if not enough question, then show all of them

                    rptQuestions.DataSource = dt;
                    rptQuestions.DataBind();
                }
                catch (Exception ex)
                {
                    lblResult.Text = "Error: " + ex.Message;
                    lblResult.Visible = true;
                }
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "stopTimer", "stopTimer();", true);

            int totalScore = 0;
            int maxScore = 0;
            int correctCount = 0;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                foreach (RepeaterItem item in rptQuestions.Items)
                {
                    HiddenField hfID = (HiddenField)item.FindControl("hfQuestionID");
                    RadioButton rbA = (RadioButton)item.FindControl("rbA");
                    RadioButton rbB = (RadioButton)item.FindControl("rbB");
                    RadioButton rbC = (RadioButton)item.FindControl("rbC");
                    RadioButton rbD = (RadioButton)item.FindControl("rbD");

                    // K's UI Controls
                    Panel pnlA = (Panel)item.FindControl("pnlA");
                    Panel pnlB = (Panel)item.FindControl("pnlB");
                    Panel pnlC = (Panel)item.FindControl("pnlC");
                    Panel pnlD = (Panel)item.FindControl("pnlD");
                    Button btnExplain = (Button)item.FindControl("btnExplain");

                    string userAnswer = "";
                    if (rbA.Checked) userAnswer = "A";
                    else if (rbB.Checked) userAnswer = "B";
                    else if (rbC.Checked) userAnswer = "C";
                    else if (rbD.Checked) userAnswer = "D";

                    int qId = Convert.ToInt32(hfID.Value);
                    string sql = "SELECT CorrectAnswer, Marks FROM Questions WHERE QuestionID = @qid";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@qid", qId);

                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        string correctAnswer = dr["CorrectAnswer"].ToString();
                        int marks = Convert.ToInt32(dr["Marks"]);
                        maxScore += marks;

                        // K's Answer Highlighting Logic
                        if (correctAnswer == "A") pnlA.CssClass = "opt-correct";
                        else if (correctAnswer == "B") pnlB.CssClass = "opt-correct";
                        else if (correctAnswer == "C") pnlC.CssClass = "opt-correct";
                        else if (correctAnswer == "D") pnlD.CssClass = "opt-correct";

                        if (userAnswer != correctAnswer && userAnswer != "")
                        {
                            if (userAnswer == "A") pnlA.CssClass = "opt-wrong";
                            else if (userAnswer == "B") pnlB.CssClass = "opt-wrong";
                            else if (userAnswer == "C") pnlC.CssClass = "opt-wrong";
                            else if (userAnswer == "D") pnlD.CssClass = "opt-wrong";
                        }

                        if (userAnswer == correctAnswer)
                        {
                            totalScore += marks;
                            correctCount++;
                        }

                        // Enable AI Explanation
                        btnExplain.Visible = true;
                        btnExplain.CommandArgument = $"{userAnswer}|||{correctAnswer}";
                    }
                    dr.Close();

                    // Disable radio buttons after submission
                    rbA.Enabled = false; rbB.Enabled = false; rbC.Enabled = false; rbD.Enabled = false;
                }

                // Database Save Logic
                int currentUserId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;
                if (currentUserId == 0) { Response.Redirect("~/ZerotoAI/Login.aspx"); return; }

                int currentQuizId = 1;
                string currentTopic = Request.QueryString["topic"];
                if (currentTopic == "Robo") currentQuizId = 2;
                else if (currentTopic == "All") currentQuizId = 3;

                string insertSql = "INSERT INTO UserProgress (UserID, QuizID, Score, CompletedDate) VALUES (@uid, @qid, @score, GETDATE())";
                SqlCommand insertCmd = new SqlCommand(insertSql, con);
                insertCmd.Parameters.AddWithValue("@uid", currentUserId);
                insertCmd.Parameters.AddWithValue("@qid", currentQuizId);
                insertCmd.Parameters.AddWithValue("@score", totalScore);
                insertCmd.ExecuteNonQuery();
            }

            // Show result
            string color = "red";
            if (totalScore >= maxScore / 2) color = "green";
            lblResult.Text = $"Finished! You got {correctCount} correct. Score: {totalScore} / {maxScore}";
            lblResult.ForeColor = System.Drawing.Color.FromName(color);
            lblResult.Visible = true;

            btnSubmit.Visible = false;
            timerContainer.Visible = false;
            btnBack.Visible = true;

            // K's Layout Change (Opens Chatbot)
            mainWrapper.Attributes["class"] = "main-wrapper mode-split";
            aiChatPanel.Visible = true;
            litChatHistory.Text = Session["ChatHistory"].ToString();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("QuizTopic.aspx");
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e) { }

        protected async void rptQuestions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Explain")
            {
                string[] args = e.CommandArgument.ToString().Split(new string[] { "|||" }, StringSplitOptions.None);
                string userAnswer = args[0] == "" ? "No Answer" : args[0];
                string correctAnswer = args[1];
                Label lblQText = (Label)e.Item.FindControl("lblQText");
                string qText = lblQText.Text;
                string userMsg = $"Please explain this question: '{qText}'. I answered '{userAnswer}', but the correct answer is '{correctAnswer}'. Tell me why gently and briefly.";

                AppendToChat("msg-user", "Can you explain the question about: " + qText + "?");
                Session["AI_Context"] = $"We are discussing this question: '{qText}'. Student chose {userAnswer}, correct is {correctAnswer}.";
                await CallGeminiAPI(userMsg);
            }
        }

        protected async void btnSendChat_Click(object sender, EventArgs e)
        {
            string userText = txtChatInput.Text.Trim();
            if (string.IsNullOrEmpty(userText)) return;
            AppendToChat("msg-user", userText);
            txtChatInput.Text = "";
            string context = Session["AI_Context"] != null ? $"[Context: {Session["AI_Context"]}] " : "";
            await CallGeminiAPI(context + userText);
        }

        private void AppendToChat(string cssClass, string message)
        {
            string newBubble = $"<div class='msg-bubble {cssClass}'>{message}</div>";
            Session["ChatHistory"] = Session["ChatHistory"].ToString() + newBubble;
            litChatHistory.Text = Session["ChatHistory"].ToString();
        }

        private async System.Threading.Tasks.Task CallGeminiAPI(string prompt)
        {
            string apiKey = ConfigurationManager.AppSettings["GeminiApiKey"];
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            try
            {
                using (HttpClient client = new HttpClient())
                {
                    string url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={apiKey}";
                    string systemInstruction = "You are a friendly and encouraging university AI tutor. Explain concepts simply. Keep responses short and easy to read.";
                    string fullPrompt = systemInstruction + "\n\n" + prompt;
                    string jsonBody = "{\"contents\": [{\"parts\": [{\"text\": \"" + fullPrompt.Replace("\"", "\\\"").Replace("\n", " ") + "\"}]}]}";
                    StringContent content = new StringContent(jsonBody, Encoding.UTF8, "application/json");
                    HttpResponseMessage response = await client.PostAsync(url, content);
                    response.EnsureSuccessStatusCode();
                    string responseString = await response.Content.ReadAsStringAsync();
                    JavaScriptSerializer js = new JavaScriptSerializer();
                    dynamic jsonResponse = js.Deserialize<dynamic>(responseString);
                    string aiText = jsonResponse["candidates"][0]["content"]["parts"][0]["text"];
                    AppendToChat("msg-ai", aiText);
                }
            }
            catch (Exception ex)
            {
                AppendToChat("msg-ai", "Oops! I'm having trouble connecting right now. Details: " + ex.Message);
            }
        }
    }
}
