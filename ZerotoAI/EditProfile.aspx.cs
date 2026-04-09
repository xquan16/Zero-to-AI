using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
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

        protected async void btnGenerateAI_Click(object sender, EventArgs e)
        {
            string prompt = txtAIPrompt.Text.Trim();

            if (string.IsNullOrEmpty(prompt))
            {
                // 1. Reset the button
                string resetScript = "document.getElementById('" + btnGenerateAI.ClientID + "').disabled = false; document.getElementById('" + btnGenerateAI.ClientID + "').value = '✨ Generate Image';";

                // 2. Dynamic Dark-Mode SweetAlert!
                string alertScript = @"
                    var isDark = localStorage.getItem('theme') === 'dark';
                    Swal.fire({
                        icon: 'warning',
                        title: 'Prompt Required',
                        text: 'Please type what you want to generate, or click the 🎲 dice button for a surprise idea!',
                        background: isDark ? '#1e293b' : '#ffffff',
                        color: isDark ? '#f8fafc' : '#334155',
                        confirmButtonColor: 'var(--bg-sidebar)'
                    });";

                ScriptManager.RegisterStartupScript(this, GetType(), "EmptyPrompt", resetScript + alertScript, true);
                return;
            }

            try
            {
                string hfToken = System.Configuration.ConfigurationManager.AppSettings["HuggingFaceToken"];

                string apiUrl = "https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell";

                string enhancedPrompt = prompt + ", flat design illustration, minimalist avatar, circular composition, solid background, high quality, vector style";
                var requestBody = new { inputs = enhancedPrompt };
                System.Web.Script.Serialization.JavaScriptSerializer js = new System.Web.Script.Serialization.JavaScriptSerializer();
                string jsonBody = js.Serialize(requestBody);

                using (System.Net.Http.HttpClient client = new System.Net.Http.HttpClient())
                {
                    client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", hfToken);
                    System.Net.Http.StringContent content = new System.Net.Http.StringContent(jsonBody, System.Text.Encoding.UTF8, "application/json");

                    System.Net.Http.HttpResponseMessage response = await client.PostAsync(apiUrl, content);

                    if (!response.IsSuccessStatusCode)
                    {
                        string errorMsg = await response.Content.ReadAsStringAsync();
                        // Truncate massive HTML error pages so they don't crash the popup
                        if (errorMsg.Length > 150) errorMsg = errorMsg.Substring(0, 150) + "... (Truncated)";
                        throw new Exception($"Error {response.StatusCode}: {errorMsg}");
                    }

                    byte[] imageBytes = await response.Content.ReadAsByteArrayAsync();
                    string mimeType = response.Content.Headers.ContentType?.MediaType ?? "image/png";
                    string base64String = Convert.ToBase64String(imageBytes);
                    string dataUrl = $"data:{mimeType};base64,{base64String}";

                    ScriptManager.RegisterStartupScript(this, GetType(), "OpenAICropper", $"openCropperWithAIImage('{dataUrl}');", true);

                    txtAIPrompt.Text = "";
                }
            }
            catch (Exception ex)
            {
                // ✨ THE SAFETY FIX 2: Strip out quotes and newlines so it NEVER breaks the JavaScript syntax!
                string safeError = ex.Message.Replace("'", "\\'").Replace("\"", "\\\"").Replace("\n", " ").Replace("\r", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "AIError", $"Swal.fire('API Error', 'Failed to generate image: {safeError}', 'error');", true);
            }
            finally
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "ResetBtn2", "document.getElementById('" + btnGenerateAI.ClientID + "').disabled = false; document.getElementById('" + btnGenerateAI.ClientID + "').value = '✨ Generate Image';", true);
            }
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

                    // --- NEW SECURITY FEATURE: Check if password was changed ---
                    if (passwordHash != null)
                    {
                        // 1. Instantly destroy their active session
                        Session.Clear();
                        Session.Abandon();

                        // 2. Trigger a beautiful SweetAlert popup, then redirect to Login
                        string script = @"
                            var isDarkMode = document.body.getAttribute('data-theme') === 'dark';
                            Swal.fire({
                                icon: 'success',
                                title: 'Password Updated',
                                text: 'For your security, please log in again with your new password.',
                                confirmButtonText: 'Go to Login',
                                confirmButtonColor: '#0d9488',
                                background: isDarkMode ? '#1e293b' : '#ffffff',
                                color: isDarkMode ? '#f8fafc' : '#334155',
                                backdrop: 'rgba(0,0,0,0.7)',
                                allowOutsideClick: false 
                            }).then((result) => {
                                window.location.href = '/ZerotoAI/Login.aspx';
                            });";

                        ClientScript.RegisterStartupScript(this.GetType(), "PwdChanged", script, true);
                        return; // Stop the code here so it doesn't redirect to dashboard!
                    }

                    // --- NORMAL PROFILE UPDATE (If they didn't change their password) ---

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
