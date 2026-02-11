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

            // 2. PASSWORD HASHING (Based on Lab 10) 
            // Step A: Create a random salt
            RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
            byte[] saltByte = new byte[8];
            rng.GetBytes(saltByte);
            string salt = Convert.ToBase64String(saltByte);

            // Step B: Hash the password using the salt
            Rfc2898DeriveBytes hash = new Rfc2898DeriveBytes(passTxt.Text, saltByte, 10000);
            byte[] hashByte = hash.GetBytes(20);
            string passwordHash = Convert.ToBase64String(hashByte);

            // 3. DATABASE INSERTION (Based on Lab 02/04) 
            try
            {
                // Get connection string from Web.config (Ensure name matches your Web.config!)
                string connStr = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // Check if Username or Email already exists
                    string checkQuery = "SELECT COUNT(*) FROM [Users] WHERE Username = @Username OR Email = @Email";
                    SqlCommand checkCmd = new SqlCommand(checkQuery, conn);
                    checkCmd.Parameters.AddWithValue("@Username", userTxt.Text);
                    checkCmd.Parameters.AddWithValue("@Email", emailTxt.Text);

                    int count = (int)checkCmd.ExecuteScalar();

                    if (count > 0)
                    {
                        msgLbl.Text = "Username or Email already taken.";
                        msgLbl.ForeColor = Color.Red;
                        msgLbl.Visible = true;
                        return;
                    }

                    // Insert new user
                    string insertQuery = @"INSERT INTO [Users] 
                                   (FirstName, LastName, Username, Email, PasswordHash, Salt, Role, IsBanned, CreatedAt) 
                                   VALUES 
                                   (@First, @Last, @User, @Email, @Pass, @Salt, 'Member', 0, GETDATE())";

                    SqlCommand cmd = new SqlCommand(insertQuery, conn);

                    // Add parameters to prevent SQL Injection
                    cmd.Parameters.AddWithValue("@First", fnameTxt.Text);
                    cmd.Parameters.AddWithValue("@Last", lnameTxt.Text);
                    cmd.Parameters.AddWithValue("@User", userTxt.Text);
                    cmd.Parameters.AddWithValue("@Email", emailTxt.Text);
                    cmd.Parameters.AddWithValue("@Pass", passwordHash); // Store the HASH, not plain text
                    cmd.Parameters.AddWithValue("@Salt", salt);         // Store the SALT

                    cmd.ExecuteNonQuery();

                    // Write info to a file (for development purposes only)
                    string debugFilePath = Server.MapPath("~/App_Data/userPassword.txt");
                    string debugLine = $"{userTxt.Text} | {passTxt.Text} | {salt} | {passwordHash}" + Environment.NewLine;
                    File.AppendAllText(debugFilePath, debugLine);

                    // 4. SUCCESS & REDIRECT
                    // Log the user in immediately via Session
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