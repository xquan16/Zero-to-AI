using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Text.RegularExpressions;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Zero_to_AI.ZerotoAI
{
    public partial class EditProfile : System.Web.UI.Page
    {
        // Connection string used throughout the page
        string connStr = ConfigurationManager.ConnectionStrings["db"].ConnectionString;

        // --- Helper methods (defined first per coding style) ---
        private void ShowError(string msg)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = "lbl-message text-error";
            lblMsg.Visible = true;
        }

        // Load profile and populate controls
        private void LoadUserProfile()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string query = "SELECT * FROM [Users] WHERE Username = @User";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@User", Session["Username"]);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Populate Textboxes
                            txtFirst.Text = reader["FirstName"].ToString();
                            txtLast.Text = reader["LastName"].ToString();
                            txtEmail.Text = reader["Email"].ToString();
                            txtUsername.Text = reader["Username"].ToString();

                            // Handle Image
                            string pic = reader["ProfilePicture"].ToString();
                            imgPreview.ImageUrl = !string.IsNullOrEmpty(pic) ? "~/images/" + pic : "~/images/default_user.png";
                        }
                    }
                }
            }
            catch (Exception)
            {
                lblMsg.Text = "Error loading profile.";
                lblMsg.CssClass = "text-error";
                lblMsg.Visible = true;
            }
        }

        // Get current profile picture filename (or null)
        private string GetCurrentProfilePic(string username)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string query = "SELECT ProfilePicture FROM [Users] WHERE Username=@User";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@User", username);

                    object result = cmd.ExecuteScalar();
                    return (result != null && result != DBNull.Value) ? result.ToString() : null;
                }
            }
            catch
            {
                return null; // Swallow DB errors here
            }
        }

        // Check if username exists (used for validation)
        private bool IsUsernameTaken(string user)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string query = "SELECT COUNT(*) FROM [Users] WHERE Username=@User";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@User", user);
                int count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }

        // Return numeric UserID for given username (or 0 if not found)
        private int GetUserIdByUsername(string username)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string q = "SELECT UserID FROM [Users] WHERE Username=@User";
                    SqlCommand cmd = new SqlCommand(q, conn);
                    cmd.Parameters.AddWithValue("@User", username);
                    object o = cmd.ExecuteScalar();
                    if (o != null && o != DBNull.Value)
                        return Convert.ToInt32(o);
                }
            }
            catch { }
            return 0;
        }

        // Make a safe filename from original name
        private string SanitizeFileName(string name)
        {
            if (string.IsNullOrEmpty(name)) return "file";
            // Keep only letters, numbers, underscore, dash and dot
            string cleaned = Path.GetFileName(name);
            cleaned = Regex.Replace(cleaned, "[^a-zA-Z0-9_\\-.]", "_");
            if (cleaned.Length > 120) cleaned = cleaned.Substring(cleaned.Length - 120);
            return cleaned;
        }

        // --- Dashboard Router Helper ---
        private void RedirectToDashboard()
        {
            // Get the user's role from the session (default to Member if missing)
            string role = Session["UserRole"] != null ? Session["UserRole"].ToString() : "Member";

            if (role == "Admin")
                Response.Redirect("~/Admin/AdminDashboard.aspx");
            else if (role == "Editor")
                Response.Redirect("~/Editor/EditorDashboard.aspx");
            else
                Response.Redirect("~/Member/Dashboard.aspx");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] == null)
            {
                Response.Redirect("Login.aspx");
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
            }
        }

        // --- Event handlers ---
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string currentUsername = Session["Username"].ToString();
            string newUsername = txtUsername.Text.Trim();
            string filename = null;
            string passwordHash = null;

            lblMsg.Visible = false;

            // 1. Password Validation
            if (!string.IsNullOrEmpty(txtNewPass.Text))
            {
                if (txtNewPass.Text != txtConfirmPass.Text)
                {
                    ShowError("Passwords do not match.");
                    return;
                }
                passwordHash = BCrypt.Net.BCrypt.HashPassword(txtNewPass.Text);
            }

            // 2. Username Validation
            if (currentUsername != newUsername)
            {
                if (IsUsernameTaken(newUsername)) { ShowError("Username taken."); return; }
            }

            // 3. HANDLE CROPPED IMAGE UPLOAD (Base64)
            string base64Data = hfCroppedImage.Value; // Read from Hidden Field

            // If client provided base64 (cropped) image, use it. Otherwise, check FileUpload control.
            if (!string.IsNullOrEmpty(base64Data))
            {
                try
                {
                    // The string looks like: "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
                    string cleanBase64 = base64Data.Split(',')[1];
                    byte[] imageBytes = Convert.FromBase64String(cleanBase64);

                    // Prefer stable filename: {UserID}_{originalName} when possible
                    int userId = GetUserIdByUsername(currentUsername);
                    // Try to read original filename from posted hidden field
                    string original = string.Empty;
                    foreach (string k in Request.Form.AllKeys)
                    {
                        if (!string.IsNullOrEmpty(k) && k.EndsWith("hfOriginalFileName"))
                        {
                            original = Request.Form[k] ?? string.Empty;
                            break;
                        }
                    }
                    string safe = SanitizeFileName(original);
                    string ext = ".jpg"; // default since JS outputs jpeg
                    if (!string.IsNullOrEmpty(safe))
                    {
                        string extCandidate = Path.GetExtension(safe).ToLowerInvariant();
                        if (extCandidate == ".png" || extCandidate == ".jpg" || extCandidate == ".jpeg") ext = extCandidate;
                    }

                    if (userId > 0)
                    {
                        filename = userId + "_" + (string.IsNullOrEmpty(safe) ? "avatar" : safe);
                        if (!Path.HasExtension(filename)) filename += ext;
                    }
                    else
                    {
                        filename = Guid.NewGuid().ToString() + ext;
                    }

                    string savePath = Server.MapPath("~/images/") + filename;

                    // --- DELETE OLD IMAGE LOGIC ---
                    string oldPic = GetCurrentProfilePic(currentUsername);
                    if (!string.IsNullOrEmpty(oldPic) && oldPic != "default_user.png")
                    {
                        string oldPath = Server.MapPath("~/images/") + oldPic;
                        if (File.Exists(oldPath))
                        {
                            try { File.Delete(oldPath); } catch { /* Ignore lock errors */ }
                        }
                    }

                    // Save New Image
                    File.WriteAllBytes(savePath, imageBytes);
                }
                catch (Exception ex)
                {
                    ShowError("Image Error: " + ex.Message);
                    return;
                }
            }

            else if (fuProfilePic.HasFile)
            {
                try
                {
                    // Use uploaded file. Generate filename as: {UserID}_{sanitizedOriginal}
                    int userId = GetUserIdByUsername(currentUsername);
                    if (userId == 0) { ShowError("User not found."); return; }

                    string original = fuProfilePic.FileName;
                    string safe = SanitizeFileName(original);
                    string newFilename = userId + "_" + safe;

                    // Ensure extension is jpg or png; convert if necessary by saving as uploaded bytes
                    string ext = Path.GetExtension(safe).ToLowerInvariant();
                    if (ext != ".jpg" && ext != ".jpeg" && ext != ".png")
                    {
                        // default to jpg
                        ext = ".jpg";
                    }
                    filename = newFilename + ext;
                    string savePath = Server.MapPath("~/images/") + filename;

                    // Delete old image if exists
                    string oldPic = GetCurrentProfilePic(currentUsername);
                    if (!string.IsNullOrEmpty(oldPic) && oldPic != "default_user.png")
                    {
                        string oldPath = Server.MapPath("~/images/") + oldPic;
                        if (File.Exists(oldPath))
                        {
                            try { File.Delete(oldPath); } catch { }
                        }
                    }

                    // Save file to images folder
                    fuProfilePic.SaveAs(savePath);
                }
                catch (Exception ex)
                {
                    ShowError("Upload Error: " + ex.Message);
                    return;
                }
            }

            // 4. DATABASE UPDATE
            try
            {
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();
                    string query = @"UPDATE [Users] SET 
                            FirstName=@First, LastName=@Last, Email=@Email, Username=@NewUser" +
                                    (passwordHash != null ? ", PasswordHash=@Pass" : "") +
                                    (filename != null ? ", ProfilePicture=@Pic" : "") +
                                    " WHERE Username=@OldUser";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@First", txtFirst.Text.Trim());
                    cmd.Parameters.AddWithValue("@Last", txtLast.Text.Trim());
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@NewUser", newUsername);
                    cmd.Parameters.AddWithValue("@OldUser", currentUsername);

                    if (passwordHash != null) cmd.Parameters.AddWithValue("@Pass", passwordHash);
                    if (filename != null) cmd.Parameters.AddWithValue("@Pic", filename);

                    cmd.ExecuteNonQuery();

                    // 5. UPDATE SESSION
                    Session["Username"] = newUsername;
                    if (filename != null) Session["UserProfilePic"] = filename;

                    lblMsg.Text = "Profile updated successfully!";
                    lblMsg.CssClass = "lbl-message text-success";
                    lblMsg.Visible = true;

                    // Success Redirect
                    RedirectToDashboard();
                }
            }
            catch (Exception ex)
            {
                ShowError("Database Error: " + ex.Message);
            }
        }


        protected void btnDiscard_Click(object sender, EventArgs e)
        {
            RedirectToDashboard();
        }
    }
}
