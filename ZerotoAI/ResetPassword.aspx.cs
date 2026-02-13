using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BCrypt.Net;

namespace Zero_to_AI.ZerotoAI
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        string connStr = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        // VERIFY USER AND EMAIL
        protected void btnVerify_Click(object sender, EventArgs e)
        {
            lblVerifyMsg.Visible = false;
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    // Check if a user exists with THIS Username AND THIS Email
                    string query = "SELECT COUNT(*) FROM [Users] WHERE Username = @User AND Email = @Email";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@User", txtUserVerify.Text.Trim());
                    cmd.Parameters.AddWithValue("@Email", txtEmailVerify.Text.Trim());

                    int count = (int)cmd.ExecuteScalar();

                    if (count > 0)
                    {
                        // SUCCESS
                        pnlVerify.Visible = false;
                        pnlReset.Visible = true;
                        hfResetUsername.Value = txtUserVerify.Text.Trim();
                    }
                    else
                    {
                        // ERROR: Use the specific Verify Label
                        lblVerifyMsg.Text = "Username and Email do not match.";
                        lblVerifyMsg.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                lblVerifyMsg.Text = "Error: " + ex.Message;
                lblVerifyMsg.Visible = true;
            }
        }

        // UPDATE PASSWORD
        protected void btnReset_Click(object sender, EventArgs e)
        {
            lblResetMsg.Visible = false;
            // 1. Validate Passwords Match
            if (txtNewPass.Text != txtConfirmPass.Text)
            {
                lblResetMsg.Text = "Passwords do not match.";
                lblResetMsg.Visible = true;
                return;
            }

            if (string.IsNullOrWhiteSpace(txtNewPass.Text))
            {
                lblResetMsg.Text = "Password cannot be empty.";
                lblResetMsg.Visible = true;
                return;
            }

            try
            {
                // 2. Hash the New Password
                string newHash = BCrypt.Net.BCrypt.HashPassword(txtNewPass.Text);

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    // 3. Update the Database
                    // We use the Username stored in the HiddenField from Step 1
                    string updateQuery = "UPDATE [Users] SET PasswordHash = @Hash WHERE Username = @User";
                    SqlCommand cmd = new SqlCommand(updateQuery, conn);
                    cmd.Parameters.AddWithValue("@Hash", newHash);
                    cmd.Parameters.AddWithValue("@User", hfResetUsername.Value);

                    cmd.ExecuteNonQuery();

                    // 4. Success! Redirect to Login
                    Response.Redirect("Login.aspx");
                }
            }
            catch (Exception ex)
            {
                lblResetMsg.Text = "Error updating password: " + ex.Message;
                lblResetMsg.Visible = true;
            }
        }
    }
}