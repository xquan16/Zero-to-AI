using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;

namespace Zero_to_AI.Editor
{
    public partial class EditorEditQuiz : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            //if (Session["UserName"] == null || Session["UserRole"].ToString() != "Editor")
            //{
            //    Response.Redirect("~/Login.aspx");
            //    return;
            //}

            if (!IsPostBack)
            {
                LoadQuizList();
                LoadQuestions();
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
                string sql = "INSERT INTO ActivityLogs (UserName, ActionType, Description, ActionDate) VALUES (@user, @action, @desc, GETDATE())";
                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@user", currentUser);
                cmd.Parameters.AddWithValue("@action", action);
                cmd.Parameters.AddWithValue("@desc", detail);

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
                lblMsg.Text = "Question Added Successfully!";
                lblMsg.ForeColor = System.Drawing.Color.Green;

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