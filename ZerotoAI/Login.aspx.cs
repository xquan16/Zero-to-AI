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
                    string query = "SELECT UserID, PasswordHash, Role, FirstName, ProfilePicture, IsBanned FROM [Users] WHERE Username = @User"; 
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
                                // Check if the user is banned FIRST
                                bool isBanned = reader["IsBanned"] != DBNull.Value && Convert.ToBoolean(reader["IsBanned"]);

                                if (isBanned)
                                {
                                    // Save the UserID and show the banned screen
                                    hfBannedUserID.Value = reader["UserID"].ToString();
                                    pnlLoginForm.Visible = false;
                                    pnlBanned.Visible = true;
                                    return; // Stop login process here!
                                }

                                // SUCCESS - Not banned!
                                Session["UserID"] = reader["UserID"].ToString();
                                Session["Username"] = userTxt.Text;
                                Session["UserRole"] = role;
                                Session["FirstName"] = firstName;
                                Session["UserProfilePic"] = string.IsNullOrEmpty(profilePic) ? "default_user.png" : profilePic;

                                if (role == "Admin")
                                    Response.Redirect("~/Admin/AdminDashboard.aspx");
                                else if (role == "Editor")
                                    Response.Redirect("~/Editor/EditorDashboard.aspx");
                                else
                                    Response.Redirect("~/Member/Dashboard.aspx");
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

        protected void btnSubmitAppeal_Click(object sender, EventArgs e)
        {
            string appealText = txtAppeal.Text.Trim();

            if (string.IsNullOrEmpty(appealText))
            {
                lblAppealStatus.Text = "Please enter a message before submitting.";
                lblAppealStatus.CssClass = "appeal-status text-danger";
                return;
            }

            int userId = Convert.ToInt32(hfBannedUserID.Value);

            try
            {
                using (SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["db"].ConnectionString))
                {
                    // IMPORTANT: Change "MemberFeedback" and "MessageText" to match your actual database table
                    string sql = "INSERT INTO Feedback (UserID, Message) VALUES (@uid, @msg)";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@uid", userId);
                        cmd.Parameters.AddWithValue("@msg", "[BANNED APPEAL] " + appealText);

                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                lblAppealStatus.Text = "Your appeal has been sent to the administrators.";
                lblAppealStatus.CssClass = "appeal-status text-success";
                txtAppeal.Text = "";
                btnSubmitAppeal.Enabled = false;
            }
            catch (Exception ex)
            {
                lblAppealStatus.Text = "Error sending message: " + ex.Message;
                lblAppealStatus.CssClass = "appeal-status text-danger";
            }
        }

        protected void btnBackToLogin_Click(object sender, EventArgs e)
        {
            pnlBanned.Visible = false;
            pnlLoginForm.Visible = true;
            lblAppealStatus.Text = "";
            txtAppeal.Text = "";
            btnSubmitAppeal.Enabled = true;
        }
    }
}