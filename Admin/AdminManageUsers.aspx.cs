using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BCrypt.Net;

namespace Zero_to_AI.Admin
{
    public partial class AdminManageUsers : System.Web.UI.Page
    {
        private readonly string _conn = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("~/ZerotoAI/Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                ViewState["StatusTab"] = "All";
                LoadUsers();
            }

            lblMessage.Visible = false;
            lblGridMessage.Visible = false;
            lblFormMessage.Visible = false;
        }

        // --- FILTERS & TABS ---
        protected void tabStatus_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            ViewState["StatusTab"] = btn.CommandArgument;

            tabAll.CssClass = "tab-btn";
            tabActive.CssClass = "tab-btn";
            tabBanned.CssClass = "tab-btn";
            btn.CssClass = "tab-btn admin-active";

            LoadUsers();
        }

        protected void ddlRoleFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadUsers();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadUsers(txtSearch.Text.Trim());
        }

        // --- DATA BINDING ---
        private void LoadUsers(string searchQuery = "")
        {
            string statusFilter = ViewState["StatusTab"].ToString();
            string roleFilter = ddlRoleFilter.SelectedValue;

            string sql = "SELECT UserID, Username, Email, Role, ISNULL(IsBanned, 0) AS IsBanned, CreatedAt FROM Users WHERE Role != 'Admin'";

            if (statusFilter == "Active") sql += " AND (IsBanned = 0 OR IsBanned IS NULL)";
            else if (statusFilter == "Banned") sql += " AND IsBanned = 1";

            if (roleFilter != "All") sql += " AND Role = @role";
            if (!string.IsNullOrEmpty(searchQuery)) sql += " AND Username LIKE @search";

            sql += " ORDER BY Role, Username";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (roleFilter != "All") cmd.Parameters.AddWithValue("@role", roleFilter);
                if (!string.IsNullOrEmpty(searchQuery)) cmd.Parameters.AddWithValue("@search", "%" + searchQuery + "%");

                using (SqlDataAdapter da = new SqlDataAdapter(cmd)) da.Fill(dt);
            }

            gvUsers.DataSource = dt;
            gvUsers.DataBind();

            lblSearchError.Visible = dt.Rows.Count == 0;
            lblSearchError.Text = dt.Rows.Count == 0 ? "No users found matching your filters." : "";
        }

        protected void gvUsers_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string role = DataBinder.Eval(e.Row.DataItem, "Role").ToString();
                LinkButton btnEdit = (LinkButton)e.Row.FindControl("btnEdit");

                if (role == "Admin")
                {
                    btnEdit.Visible = false; // Admins cannot edit other Admins
                }
            }
        }

        // --- GRID ACTIONS (BAN/EDIT) ---
        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int targetUserId = Convert.ToInt32(e.CommandArgument);

            // Hide previous messages on new clicks
            lblMessage.Visible = false;
            lblGridMessage.Visible = false;

            if (e.CommandName == "ToggleBan")
            {
                string sql = "UPDATE Users SET IsBanned = CASE WHEN IsBanned = 1 THEN 0 ELSE 1 END WHERE UserID = @uid";
                using (SqlConnection conn = new SqlConnection(_conn))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uid", targetUserId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // Use the new localized Grid Message panel!
                lblGridMessage.Text = "<i class='fas fa-check-circle'></i> User status updated successfully!";
                lblGridMessage.Visible = true;

                LoadUsers(txtSearch.Text.Trim());
            }
            else if (e.CommandName == "EditUser")
            {
                LoadUserIntoForm(targetUserId);
            }
        }

        // --- ADD/EDIT FORM LOGIC ---
        protected void btnShowAddUser_Click(object sender, EventArgs e)
        {
            lblFormMessage.Visible = false;
            hfEditUserID.Value = "";
            txtFirst.Text = "";
            txtLast.Text = "";
            txtUsername.Text = "";
            txtEmail.Text = "";
            txtPassword.Text = "";
            ddlRole.SelectedValue = "Member";

            lblFormTitle.Text = "Add New User";
            pnlUserForm.Visible = true;
            txtPassword.Attributes["placeholder"] = "Default: password123 (Please inform the user to change password)";
        }

        protected void btnCancelForm_Click(object sender, EventArgs e)
        {
            lblFormMessage.Visible = false;
            pnlUserForm.Visible = false;
        }

        private void LoadUserIntoForm(int userId)
        {
            lblFormMessage.Visible = false;
            string sql = "SELECT FirstName, LastName, Username, Email, Role FROM Users WHERE UserID = @uid";
            using (SqlConnection conn = new SqlConnection(_conn))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        txtFirst.Text = dr["FirstName"].ToString();
                        txtLast.Text = dr["LastName"].ToString();
                        txtUsername.Text = dr["Username"].ToString();
                        txtEmail.Text = dr["Email"].ToString();
                        ddlRole.SelectedValue = dr["Role"].ToString();

                        hfEditUserID.Value = userId.ToString();
                        lblFormTitle.Text = "Edit User: " + txtUsername.Text;
                        txtPassword.Text = "";
                        pnlUserForm.Visible = true;
                        txtPassword.Attributes["placeholder"] = "Leave blank to keep existing";
                    }
                }
            }
        }

        protected void btnSaveUser_Click(object sender, EventArgs e)
        {
            string first = txtFirst.Text.Trim();
            string last = txtLast.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string role = ddlRole.SelectedValue;
            string password = txtPassword.Text.Trim();

            // Clear previous messages
            lblFormMessage.Visible = false;
            lblMessage.Visible = false;

            // 1. Basic Input Validation (ERROR -> Show in Form as RED)
            if (string.IsNullOrEmpty(first) || string.IsNullOrEmpty(last) || string.IsNullOrEmpty(username) || string.IsNullOrEmpty(email))
            {
                lblFormMessage.Text = "<i class='fas fa-exclamation-triangle'></i> All fields except password are required.";
                lblFormMessage.ForeColor = System.Drawing.Color.Red;
                lblFormMessage.Visible = true;
                return;
            }

            using (SqlConnection conn = new SqlConnection(_conn))
            {
                conn.Open();

                // 2. Duplicate Username & Email Check (ERROR -> Show in Form as RED)
                string checkQuery = "SELECT Username, Email FROM Users WHERE (Username = @un OR Email = @email)";
                if (!string.IsNullOrEmpty(hfEditUserID.Value))
                {
                    checkQuery += " AND UserID != @uid";
                }

                using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                {
                    checkCmd.Parameters.AddWithValue("@un", username);
                    checkCmd.Parameters.AddWithValue("@email", email);
                    if (!string.IsNullOrEmpty(hfEditUserID.Value))
                    {
                        checkCmd.Parameters.AddWithValue("@uid", Convert.ToInt32(hfEditUserID.Value));
                    }

                    bool isUserTaken = false;
                    bool isEmailTaken = false;

                    using (SqlDataReader dr = checkCmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            if (dr["Username"].ToString().Equals(username, StringComparison.OrdinalIgnoreCase)) isUserTaken = true;
                            if (dr["Email"].ToString().Equals(email, StringComparison.OrdinalIgnoreCase)) isEmailTaken = true;
                        }
                    }

                    if (isUserTaken || isEmailTaken)
                    {
                        lblFormMessage.Text = isUserTaken ? "<i class='fas fa-exclamation-triangle'></i> Username is already taken." : "<i class='fas fa-exclamation-triangle'></i> Email is already registered.";
                        lblFormMessage.ForeColor = System.Drawing.Color.Red;
                        lblFormMessage.Visible = true;
                        return; // Stop the save process so the form stays open
                    }
                }

                // 3. Insert or Update Logic (SUCCESS -> Close Form, Show Global Message as GREEN)
                if (string.IsNullOrEmpty(hfEditUserID.Value))
                {
                    // INSERT NEW USER
                    if (string.IsNullOrEmpty(password)) password = "password123";
                    string hashedPass = BCrypt.Net.BCrypt.HashPassword(password);

                    string sqlInsert = "INSERT INTO Users (FirstName, LastName, Username, Email, PasswordHash, Role, CreatedAt, IsBanned) VALUES (@fn, @ln, @un, @email, @pass, @role, GETDATE(), 0)";
                    using (SqlCommand cmd = new SqlCommand(sqlInsert, conn))
                    {
                        cmd.Parameters.AddWithValue("@fn", first);
                        cmd.Parameters.AddWithValue("@ln", last);
                        cmd.Parameters.AddWithValue("@un", username);
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@pass", hashedPass);
                        cmd.Parameters.AddWithValue("@role", role);
                        cmd.ExecuteNonQuery();
                    }
                    lblMessage.Text = "<i class='fas fa-check'></i> New user added successfully!";
                }
                else
                {
                    // UPDATE EXISTING USER
                    int userId = Convert.ToInt32(hfEditUserID.Value);
                    string sqlUpdate = "UPDATE Users SET FirstName = @fn, LastName = @ln, Username = @un, Email = @email, Role = @role";

                    if (!string.IsNullOrEmpty(password))
                    {
                        sqlUpdate += ", PasswordHash = @pass";
                    }
                    sqlUpdate += " WHERE UserID = @uid";

                    using (SqlCommand cmd = new SqlCommand(sqlUpdate, conn))
                    {
                        cmd.Parameters.AddWithValue("@fn", first);
                        cmd.Parameters.AddWithValue("@ln", last);
                        cmd.Parameters.AddWithValue("@un", username);
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@role", role);
                        cmd.Parameters.AddWithValue("@uid", userId);

                        if (!string.IsNullOrEmpty(password))
                        {
                            string hashedPass = BCrypt.Net.BCrypt.HashPassword(password);
                            cmd.Parameters.AddWithValue("@pass", hashedPass);
                        }

                        cmd.ExecuteNonQuery();
                    }
                    lblMessage.Text = "<i class='fas fa-check'></i> User updated successfully!";
                }
            }

            // Close the form on success and show the green success message globally
            pnlUserForm.Visible = false;
            lblMessage.ForeColor = System.Drawing.Color.Green;
            lblMessage.Visible = true;
            LoadUsers();
        }
    }
}

