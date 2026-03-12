using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.Admin
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Check
            if (Session["UserID"] == null || Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string username = Session["Username"] != null ? Session["Username"].ToString() : "Admin";
                lblWelcome.Text = "Welcome Back, " + username;

                // Defaults
                ViewState["FbTab"] = "All";
                ViewState["UserTab"] = "All";

                LoadSystemStats();
                LoadFeedback();
                LoadUsers();
            }
            lblMessage.Visible = false; // Hide success banners on new clicks
        }

        private void LoadSystemStats()
        {
            using (SqlConnection conn = new SqlConnection(_conn))
            {
                conn.Open();
                // Count Published Articles
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Articles WHERE Status = 'Published'", conn))
                    lblAdCourseTotal.Text = (cmd.ExecuteScalar() ?? 0).ToString();

                // Count Total Questions
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Questions", conn))
                    lblAdQuizTotal.Text = (cmd.ExecuteScalar() ?? 0).ToString();

                lblAdSimTotal.Text = "0"; // Placeholder
            }
        }

        // ── FEEDBACK TABS & LOGIC ──────────────────────────────────────────
        protected void tabFb_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            ViewState["FbTab"] = btn.CommandArgument;

            tabFbAll.CssClass = "tab-btn";
            tabFbUnread.CssClass = "tab-btn";
            tabFbRead.CssClass = "tab-btn";
            btn.CssClass = "tab-btn admin-active"; // Use Red Admin Theme

            LoadFeedback();
        }

        private void LoadFeedback()
        {
            string filter = ViewState["FbTab"].ToString();
            string sql = "SELECT f.FeedbackID, f.Message, f.Date, f.Status, f.AdminReply, u.Username FROM Feedback f INNER JOIN Users u ON f.UserID = u.UserID";

            if (filter == "Unread") sql += " WHERE f.Status = 'Unread'";
            else if (filter == "Read") sql += " WHERE f.Status = 'Read'";

            sql += " ORDER BY f.Date DESC"; // Latest on top!

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
                da.Fill(dt);

            rptAdminFeedback.DataSource = dt;
            rptAdminFeedback.DataBind();

            lblNoFeedbackAdmin.Visible = dt.Rows.Count == 0;
            rptAdminFeedback.Visible = dt.Rows.Count > 0;
        }

        protected void rptAdminFeedback_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Reply")
            {
                int feedbackId = Convert.ToInt32(e.CommandArgument);
                TextBox txtAdminReply = (TextBox)e.Item.FindControl("txtAdminReply");
                string replyText = txtAdminReply.Text.Trim();

                if (string.IsNullOrEmpty(replyText)) return;

                string sql = "UPDATE Feedback SET AdminReply = @reply, Status = 'Read' WHERE FeedbackID = @fid";
                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@reply", replyText);
                    cmd.Parameters.AddWithValue("@fid", feedbackId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                lblMessage.Text = "<i class='fas fa-check'></i> Reply sent successfully!";
                lblMessage.Visible = true;
                LoadFeedback();
            }
        }

        // ── USER MANAGEMENT TABS & LOGIC ───────────────────────────────────
        protected void tabUser_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            ViewState["UserTab"] = btn.CommandArgument;

            tabUserAll.CssClass = "tab-btn";
            tabUserEditors.CssClass = "tab-btn";
            tabUserMembers.CssClass = "tab-btn";
            tabUserBanned.CssClass = "tab-btn";
            btn.CssClass = "tab-btn admin-active"; // Use Red Admin Theme

            txtSearchUser.Text = "";
            LoadUsers();
        }

        protected void btnSearchUser_Click(object sender, EventArgs e)
        {
            LoadUsers(txtSearchUser.Text.Trim());
        }

        private void LoadUsers(string searchQuery = "")
        {
            string filter = ViewState["UserTab"].ToString();

            // UPDATED: Base query explicitly excludes Admins
            string sql = "SELECT UserID, Username, Role, ISNULL(IsBanned, 0) AS IsBanned FROM Users WHERE Role != 'Admin'";

            // Apply new filters
            if (filter == "Editors") sql += " AND Role = 'Editor'";
            else if (filter == "Members") sql += " AND Role = 'Member'";
            else if (filter == "Banned") sql += " AND IsBanned = 1";

            if (!string.IsNullOrEmpty(searchQuery))
            {
                sql += " AND Username LIKE @search";
            }

            sql += " ORDER BY Role, Username";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(searchQuery))
                    cmd.Parameters.AddWithValue("@search", "%" + searchQuery + "%");

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            gvUsers.DataSource = dt;
            gvUsers.DataBind();

            lblSearchError.Visible = dt.Rows.Count == 0;
            if (dt.Rows.Count == 0) lblSearchError.Text = "No users found.";
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ToggleBan")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);
                string sql = "UPDATE Users SET IsBanned = CASE WHEN IsBanned = 1 THEN 0 ELSE 1 END WHERE UserID = @uid";

                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", targetUserId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                lblMessage.Text = "<i class='fas fa-user-shield'></i> User status has been successfully updated!";
                lblMessage.Visible = true;

                LoadUsers(txtSearchUser.Text.Trim()); // Refresh grid
            }
        }
    }
}