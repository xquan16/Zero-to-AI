using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.Cryptography; // Needed for hashing
using System.Drawing;

namespace ZerotoAI
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Clear error messages on load
            errorLbl.Visible = false;
        }

        private void ShowError(string message)
        {
            errorLbl.Text = message;
            errorLbl.Visible = true;
        }

        protected void loginBtn_Click(object sender, EventArgs e)
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // 1. Get the Hash, Salt, and Role for this username
                    string query = "SELECT PasswordHash, Salt, Role FROM [Users] WHERE Username = @User";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@User", userTxt.Text);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // 2. Retrieve stored values
                            string storedHash = reader["PasswordHash"].ToString();
                            string storedSalt = reader["Salt"].ToString();
                            string role = reader["Role"].ToString();

                            // 3. Verify the Password
                            // Convert the stored salt back to bytes
                            byte[] saltBytes = Convert.FromBase64String(storedSalt);

                            // Hash the INPUT password with the STORED salt
                            Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(passTxt.Text, saltBytes, 10000);
                            byte[] hashBytes = pbkdf2.GetBytes(20);
                            string inputHash = Convert.ToBase64String(hashBytes);

                            // 4. Compare the hashes
                            if (storedHash == inputHash)
                            {
                                // SUCCESS! Log them in
                                Session["Username"] = userTxt.Text;
                                Session["UserRole"] = role;

                                // Redirect based on Role (Optional smart redirect)
                                if (role == "Admin")
                                    Response.Redirect("~/Admin/Dashboard.aspx");
                                else
                                    Response.Redirect("~/ZerotoAI/Home.aspx");
                            }
                            else
                            {
                                // Password Wrong
                                ShowError("Invalid username or password.");
                            }
                        }
                        else
                        {
                            // Username not found
                            // Security Tip: Don't say "User not found", say "Invalid login" 
                            // so hackers don't know which usernames exist.
                            ShowError("Invalid username or password.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("An error occurred: " + ex.Message);
            }
        }
    }
}