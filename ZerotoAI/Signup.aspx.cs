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
        // Helper: show message (error or success)
        private void ShowMessage(string text, Color color)
        {
            msgLbl.Text = text;
            msgLbl.ForeColor = color;
            msgLbl.Visible = true;
        }

        // Signup button clicked
        protected void signupBtn_Click(object sender, EventArgs e)
        {
            // 1. INPUT VALIDATION
            if (string.IsNullOrWhiteSpace(fnameTxt.Text) || string.IsNullOrWhiteSpace(lnameTxt.Text) ||
                string.IsNullOrWhiteSpace(emailTxt.Text) || string.IsNullOrWhiteSpace(userTxt.Text) ||
                string.IsNullOrWhiteSpace(passTxt.Text))
            {
                ShowMessage("Please fill in all fields.", Color.Red);
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

                    // Check if Username or Email already exists
                    string checkQuery = "SELECT Username, Email FROM [Users] WHERE Username = @Username OR Email = @Email";
                    SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
                    checkCmd.Parameters.AddWithValue("@Username", userTxt.Text.Trim());
                    checkCmd.Parameters.AddWithValue("@Email", emailTxt.Text.Trim());

                    bool isUserTaken = false;
                    bool isEmailTaken = false;

                    // Use a reader to see exactly which field triggered the match
                    using (SqlDataReader reader = checkCmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (reader["Username"].ToString().Equals(userTxt.Text.Trim(), StringComparison.OrdinalIgnoreCase))
                                isUserTaken = true;

                            if (reader["Email"].ToString().Equals(emailTxt.Text.Trim(), StringComparison.OrdinalIgnoreCase))
                                isEmailTaken = true;
                        }
                    }

                    // Provide specific error messages based on what was found
                    if (isUserTaken && isEmailTaken)
                    {
                        ShowMessage("Both this Username and Email are already registered.", Color.Red);
                        return;
                    }
                    else if (isUserTaken)
                    {
                        ShowMessage("Username is already taken. Please choose another.", Color.Red);
                        return;
                    }
                    else if (isEmailTaken)
                    {
                        ShowMessage("This Email is already registered. Please log in.", Color.Red);
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

                    // Write to text file for debugging and testing
                    string debugFilePath = Server.MapPath("~/App_Data/userPassword.txt");
                    string debugLine = $"{userTxt.Text} | {passTxt.Text} | {passwordHash}" + Environment.NewLine;
                    System.IO.File.AppendAllText(debugFilePath, debugLine);

                    // 4. SUCCESS -> redirect to login
                    Response.Redirect("Login.aspx?register=success");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, Color.Red);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
