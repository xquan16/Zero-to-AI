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

            if (!IsPostBack)
            {
                // Check if we were redirected here after a successful registration
                if (Request.QueryString["register"] == "success")
                {
                    successLbl.Text = "Account created successfully! Please login.";
                    successLbl.Visible = true;
                }
            }
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

                    // 1. Get the Hash, Role, FirstName and ProfilePicture
                    string query = "SELECT PasswordHash, Role, FirstName, ProfilePicture FROM [Users] WHERE Username = @User";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@User", userTxt.Text);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string storedHash = reader["PasswordHash"].ToString();
                            string role = reader["Role"].ToString();
                            string firstName = reader["FirstName"].ToString();
                            string profilePic = reader["ProfilePicture"] == DBNull.Value ? string.Empty : reader["ProfilePicture"].ToString();

                            // 2. VERIFY PASSWORD 
                            bool isValid = BCrypt.Net.BCrypt.Verify(passTxt.Text, storedHash);

                            if (isValid)
                            {
                                // SUCCESS!
                                Session["Username"] = userTxt.Text;
                                Session["UserRole"] = role;
                                Session["FirstName"] = firstName; // For "Hi, [Name]" labels
                                // store profile pic (or default)
                                Session["UserProfilePic"] = string.IsNullOrEmpty(profilePic) ? "default_user.png" : profilePic;

                                if (role == "Admin")
                                    //Response.Redirect("~/Admin/AdminDashboard.aspx");
                                    Response.Redirect("~/ZerotoAI/Home.aspx");
                                else
                                    Response.Redirect("~/ZerotoAI/Home.aspx");
                            }
                            else
                            {
                                ShowError("Invalid username or password.");
                            }
                        }
                        else
                        {
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