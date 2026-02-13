using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Data.SqlClient;
using System.Configuration; 
using System.Security.Cryptography; // For Hashing (Lab 10)
using System.Drawing;
using BCrypt.Net;

namespace ZerotoAI
{
    public partial class Signup : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void signupBtn_Click(object sender, EventArgs e)
        {
            // 1. INPUT VALIDATION
            if (string.IsNullOrWhiteSpace(fnameTxt.Text) || string.IsNullOrWhiteSpace(lnameTxt.Text) ||
                string.IsNullOrWhiteSpace(emailTxt.Text) || string.IsNullOrWhiteSpace(userTxt.Text) ||
                string.IsNullOrWhiteSpace(passTxt.Text))
            {
                msgLbl.Text = "Please fill in all fields.";
                msgLbl.ForeColor = Color.Red;
                msgLbl.Visible = true;
                return;
            }

            // 2. PASSWORD HASHING
            string passwordHash = BCrypt.Net.BCrypt.HashPassword(passTxt.Text);

            // 3. DATABASE INSERTION
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Check if User exists
                    string checkQuery = "SELECT COUNT(*) FROM [Users] WHERE Username = @Username";
                    SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
                    checkCmd.Parameters.AddWithValue("@Username", userTxt.Text);
                    int count = (int)checkCmd.ExecuteScalar();

                    if (count > 0)
                    {
                        msgLbl.Text = "Username is already taken.";
                        msgLbl.ForeColor = Color.Red;
                        msgLbl.Visible = true;
                        return;
                    }

                    // Insert User 
                    string insertQuery = @"INSERT INTO [Users] 
                                   (FirstName, LastName, Username, Email, PasswordHash, Role, IsBanned, CreatedAt) 
                                   VALUES 
                                   (@First, @Last, @User, @Email, @Hash, 'Member', 0, GETDATE())";

                    SqlCommand cmd = new SqlCommand(insertQuery, conn);
                    cmd.Parameters.AddWithValue("@First", fnameTxt.Text);
                    cmd.Parameters.AddWithValue("@Last", lnameTxt.Text);
                    cmd.Parameters.AddWithValue("@User", userTxt.Text);
                    cmd.Parameters.AddWithValue("@Email", emailTxt.Text);
                    cmd.Parameters.AddWithValue("@Hash", passwordHash); // Store the BCrypt Hash

                    cmd.ExecuteNonQuery();

                    // 4. SUCCESS
                    Session["Username"] = userTxt.Text;
                    Session["UserRole"] = "Member";

                    Response.Redirect("~/ZerotoAI/Home.aspx");
                }
            }
            catch (Exception ex)
            {
                msgLbl.Text = "Error: " + ex.Message;
                msgLbl.ForeColor = Color.Red;
                msgLbl.Visible = true;
            }
        }
    }
}