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
    public partial class QuizTopic : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserName"] == null || Session["UserRole"].ToString() != "Member")
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }
            if (!IsPostBack)
            {
                LoadHistory();
            }
        }

 
        private void LoadHistory()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // Use JOIN to link the USerProgress and Quizzes, so that this will display the Quiz name and title
                string sql = @"
                    SELECT q.Title, u.Score, u.CompletedDate 
                    FROM UserProgress u 
                    JOIN Quizzes q ON u.QuizID = q.QuizID 
                    WHERE u.UserID = @uid  
                    ORDER BY u.CompletedDate DESC"; // DESC ensure the latest

                SqlDataAdapter da = new SqlDataAdapter(sql, con);
                da.SelectCommand.Parameters.AddWithValue("@uid", Convert.ToInt32(Session["UserID"])); 
                DataTable dt = new DataTable();

                try
                {
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        gvHistory.DataSource = dt;
                        gvHistory.DataBind();
                    }
                    else
                    {
                        // if havent do any question
                        gvHistory.Visible = false;
                        lblNoHistory.Visible = true;
                    }
                }
                catch (Exception ex)
                {
                    lblNoHistory.Text = "Error loading history: " + ex.Message;
                    lblNoHistory.Visible = true;
                }
            }
        }
    }
}
    