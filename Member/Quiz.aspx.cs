using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;

namespace Zero_to_AI.Member
{
    public partial class Quiz : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
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
                        if (userAnswer == correctAnswer)
                        {
                            totalScore += marks;
                            correctCount++;
                        }
                    }
                    dr.Close();
                }

                // 2. Save score to database
                int currentUserId = 0;

                // Safely grab the logged-in UserID
                if (Session["UserID"] != null)
                {
                    currentUserId = Convert.ToInt32(Session["UserID"]);
                }
                else
                {
                    // If they aren't logged in, redirect them to login before saving!
                    Response.Redirect("~/ZerotoAI/Login.aspx");
                    return;
                }

                int currentQuizId = 1; // default is ML
                string currentTopic = Request.QueryString["topic"];

                if (currentTopic == "Robo")
                {
                    currentQuizId = 2; // Robotics
                }
                else if (currentTopic == "All")
                {
                    currentQuizId = 3; // Mixed Challenge (Ensure QuizID 3 exists in DB!)
                }

                string insertSql = "INSERT INTO UserProgress (UserID, QuizID, Score, CompletedDate) VALUES (@uid, @qid, @score, GETDATE())";
                SqlCommand insertCmd = new SqlCommand(insertSql, con);
                insertCmd.Parameters.AddWithValue("@uid", currentUserId);
                insertCmd.Parameters.AddWithValue("@qid", currentQuizId);
                insertCmd.Parameters.AddWithValue("@score", totalScore);
                insertCmd.ExecuteNonQuery(); // write to database
            }


            // Show result
            string color = "red";
            if (totalScore >= maxScore / 2) color = "green";
            lblResult.Text = $"Finished! You got {correctCount} correct. Score: {totalScore} / {maxScore}";
            lblResult.ForeColor = System.Drawing.Color.FromName(color);
            lblResult.Visible = true;

            // Submit button invisible
            btnSubmit.Visible = false;

            // Timer invisible
            timerContainer.Visible = false;

            // Show exit button
            btnBack.Visible = true;


        }
        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("QuizTopic.aspx");
        }
    }
}
