<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EditProfile.aspx.cs" Inherits="Zero_to_AI.ZerotoAI.EditProfile" Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"></script>

    <style>
        /* Forces the main background and footer to perfectly match the darker profile card */
        .main-content, .footer {
            background-color: var(--bg-card) !important;
        }
        
        /* Softens the footer line so it blends beautifully */
        .footer {
            border-top: 1px dashed var(--border-color) !important; 
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hfCroppedImage" runat="server" />
    <asp:HiddenField ID="hfOriginalFileName" runat="server" />
    <div class="profile-full-container">
        
        <div class="profile-left-pane">
            
            <asp:Image ID="imgPreview" runat="server" CssClass="avatar-preview-large" ImageUrl="~/images/default_user.png" />

            <div class="upload-area">
                <asp:FileUpload ID="fileUploadProfile" runat="server" CssClass="file-upload-control" accept="image/*" onchange="validateImageUpload(this);" />
                <small style="opacity: 0.7; margin-top:5px;">PNG or JPG only</small>
            </div>

            <div class="ai-gen-area" style="margin-top: 30px; border-top: 1px dashed var(--border-color); padding-top: 25px; width: 100%;">
                <p style="font-weight: 800; color: var(--bg-sidebar); margin-bottom: 15px; font-size: 1.1rem;">
                    <i class="fas fa-magic"></i> AI Avatar Generator
                </p>
                
                <asp:Panel runat="server" DefaultButton="btnGenerateAI">
                    
                    <div style="position: relative; margin-bottom: 15px;">
                        
                        <asp:TextBox ID="txtAIPrompt" runat="server" CssClass="form-control" placeholder="e.g. A cute cyberpunk robot" style="margin-bottom: 0; padding-right: 45px;"></asp:TextBox>
                        
                        <button type="button" class="btn-random-prompt" onclick="generateRandomPrompt()" title="Surprise Me!">🎲</button>
                    </div>
                    
                    <asp:Button ID="btnGenerateAI" runat="server" Text="✨ Generate Image" CssClass="btn-primary-full" 
                        OnClick="btnGenerateAI_Click" 
                        OnClientClick="this.value='Generating... Please wait'; this.disabled=true;" 
                        UseSubmitBehavior="false" />
                </asp:Panel>
            </div>
        </div>

        <div id="cropModal" class="crop-modal">
            <div class="crop-container">
                <div class="crop-image-wrapper">
                    <img id="imgToCrop" src="" alt="Image to crop">
                </div>
                <div class="crop-controls">
                    <button type="button" class="btn-crop-cancel" onclick="closeCropper()">Cancel</button>
                    <button type="button" class="btn-crop-save" onclick="cropAndSave()">Crop & Set</button>
                </div>
            </div>
        </div>

        <div class="profile-right-pane">
            
            <h2 class="profile-page-title">Edit Profile</h2>

            <h4 style="color:var(--text-muted); margin-bottom:20px;">Personal Details</h4>
            
            <div class="form-row-split">
                <div class="form-group">
                    <label>First Name</label>
                    <asp:TextBox ID="txtFirst" runat="server" CssClass="form-control dirty-track"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Last Name</label>
                    <asp:TextBox ID="txtLast" runat="server" CssClass="form-control dirty-track"></asp:TextBox>
                </div>
            </div>

            <div class="form-group">
                <label>Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control dirty-track"></asp:TextBox>
            </div>

            <h4 style="color:var(--text-muted); margin:40px 0 0;">Security</h4>
            <p style="font-size: 0.85rem; color: var(--text-muted); opacity: 0.8; margin: 5px 0 20px 0;">
                <i class="fas fa-info-circle" style="color: var(--bg-sidebar);"></i> Note: Updating your password will require you to log in again.
            </p>

            <div class="form-group">
                <label>Username</label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control dirty-track"></asp:TextBox>
            </div>

            <div class="form-row-split">
                <div class="form-group">
                    <label>New Password</label>
                    <asp:TextBox ID="txtNewPass" runat="server" CssClass="form-control dirty-track" TextMode="Password" placeholder="Leave empty to keep current"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Confirm Password</label>
                    <asp:TextBox ID="txtConfirmPass" runat="server" CssClass="form-control dirty-track" TextMode="Password" placeholder="Confirm new password"></asp:TextBox>
                </div>
            </div>

            <asp:Label ID="lblMsg" runat="server" CssClass="lbl-message" style="text-align: left; margin-top: 0; font-size: 0.85rem;"></asp:Label>

            <div class="form-actions-right">
                <asp:Button ID="btnDiscard" runat="server" Text="Discard" 
                    CssClass="btn-ghost btn-discard-custom" 
                    OnClick="btnDiscard_Click" OnClientClick="return checkDiscard(event);" UseSubmitBehavior="false" />
                
                <asp:Button ID="btnSave" runat="server" Text="Save Changes" 
                    CssClass="btn-primary-full btn-save-custom" 
                    OnClick="btnSave_Click" OnClientClick="bypassDirty(); return true;" />
            </div>
        </div>
    </div>

    <script type="text/javascript">
        var cropper;
        // FIXED ID: Changed fuProfilePic to fileUploadProfile to match your HTML
        var fileInput = document.getElementById('<%= fileUploadProfile.ClientID %>');
        var cropModal = document.getElementById('cropModal');
        var imgToCrop = document.getElementById('imgToCrop');
        var hfCropped = document.getElementById('<%= hfCroppedImage.ClientID %>');
            var hfOriginal = document.getElementById('<%= hfOriginalFileName.ClientID %>');
        var imgPreview = document.getElementById('<%= imgPreview.ClientID %>');
        var isDirty = false;

        // --- NEW: The Missing Validation Function ---
        function validateImageUpload(input) {
            var filePath = input.value;
            if (!filePath) return;

            // Define the allowed image file extensions
            var allowedExtensions = /(\.jpg|\.jpeg|\.png|\.gif|\.webp)$/i;

            // If the file is NOT an image...
            if (!allowedExtensions.exec(filePath)) {
                input.value = ''; // Clear the bad file

                var isDarkMode = document.body.getAttribute("data-theme") === "dark";
                Swal.fire({
                    icon: 'error',
                    title: 'Invalid File',
                    text: 'Please upload a valid image file (JPG, PNG, GIF). Documents like PDFs are not allowed.',
                    confirmButtonText: 'Try Again',
                    confirmButtonColor: '#e11d48',
                    background: isDarkMode ? '#1e293b' : '#ffffff',
                    color: isDarkMode ? '#f8fafc' : '#334155',
                    backdrop: `rgba(0,0,0,0.7)`
                });
                return false;
            }

            // If the file IS an image, pass it to your Cropper logic!
            if (input.files && input.files.length > 0) {
                handleFileSelection(input.files[0]);
                input.value = ''; // Clear so they can re-select the same file if they cancel
            }
        }

        // --- NEW: Random Prompt Generator ---
        function generateRandomPrompt() {
            const prompts = [
                // Cyberpunk & Tech
                "A futuristic cyberpunk samurai, neon lighting, highly detailed",
                "A neon-lit cyberpunk hacker owl wearing a tiny VR headset",
                "A glowing neon hacker cat typing on a holographic keyboard",
                "A steampunk robot wearing a top hat and monocle",
                "An elegant cyborg portrait, gold and white ceramic plating",
                "A high-tech robot meditating in a peaceful zen garden",

                // Cute & Animals
                "A cute 3D pixel art brain wearing reading glasses",
                "A cute fluffy red panda wearing a futuristic spacesuit",
                "A majestic robotic owl with glowing blue eyes",
                "A cute golden retriever puppy wearing a futuristic astronaut suit",
                "A cyberpunk ninja cat with glowing neon pink katanas",
                "A cute baby dragon sleeping on a pile of glowing computer chips",

                // Sci-Fi & Space
                "An astronaut drinking coffee on the moon, digital illustration",
                "A beautiful ethereal AI hologram glowing in the dark",
                "A glowing neon jellyfish floating in a digital cyberpunk city",
                "A retro-futuristic synthwave landscape with a glowing neon grid",
                "A futuristic space pilot looking out of a spaceship window",

                // Abstract & Artistic
                "A futuristic android painted in watercolor style, pastel colors",
                "A 3D isometric cute little server room, pastel colors",
                "A magical glowing spellbook floating inside a modern server rack",
                "A beautiful stained glass window depicting a futuristic robot",
                "A glowing artificial intelligence core floating in a dark room"
            ];

            // Pick a random prompt from the list
            const randomIndex = Math.floor(Math.random() * prompts.length);
            const selectedPrompt = prompts[randomIndex];

            // Inject it into the ASP.NET Textbox
            document.getElementById('<%= txtAIPrompt.ClientID %>').value = selectedPrompt;
        }

        // --- NEW: Opens Cropper instantly with the AI Generated Image ---
        function openCropperWithAIImage(imageUrl) {

            // THE FIX: Tells the browser it is allowed to crop a downloaded image
            imgToCrop.crossOrigin = "anonymous";

            imgToCrop.src = imageUrl;
            cropModal.style.display = 'flex';

            if (cropper) cropper.destroy();
            cropper = new Cropper(imgToCrop, {
                aspectRatio: 1,
                viewMode: 1,
                autoCropArea: 1
            });
        }

        // 1. Cropper Logic (Runs after validation passes)
        function handleFileSelection(file) {
            if (!file) return;
            // store original filename so server can use it
            try { hfOriginal.value = file.name; } catch (ex) { }

            var reader = new FileReader();
            reader.onload = function (e) {
                // Show Modal
                imgToCrop.src = e.target.result;
                cropModal.style.display = 'flex';

                // Initialize Cropper (Square aspect ratio 1:1)
                if (cropper) cropper.destroy();
                cropper = new Cropper(imgToCrop, {
                    aspectRatio: 1,
                    viewMode: 1,
                    autoCropArea: 1
                });
            };
            reader.readAsDataURL(file);
        }


        // 2. Crop & Save Button
        function cropAndSave() {
            if (cropper) {
                // Get Cropped Canvas (Resize to 300x300 for storage efficiency)
                var canvas = cropper.getCroppedCanvas({
                    width: 300,
                    height: 300
                });

                // Convert to Base64 String (JPEG 90% quality)
                var base64 = canvas.toDataURL("image/jpeg", 0.9);

                // Set to Hidden Field (Server will read this)
                hfCropped.value = base64;

                // Update Preview immediately
                imgPreview.src = base64;

                // Close Modal & Mark Dirty
                closeCropper();
                markAsDirty();
            }
        }

        // 3. Close Modal
        function closeCropper() {
            cropModal.style.display = 'none';
            if (cropper) cropper.destroy();
        }

        // Dirty Flag Logic (Existing)
        function markAsDirty() { isDirty = true; }
        function bypassDirty() { isDirty = false; }
        // Intercept sidebar and navigation links with SweetAlert
        document.addEventListener('click', function (e) {
            var link = e.target.closest('a'); // Check if what they clicked is a link

            // If they clicked a link, it has a destination, AND the profile has unsaved changes...
            if (link && link.href && isDirty) {
                e.preventDefault(); // Stop the link from working immediately

                var isDarkMode = document.body.getAttribute("data-theme") === "dark";
                Swal.fire({
                    icon: 'warning',
                    title: 'Unsaved Changes',
                    text: 'You have unsaved changes. Are you sure you want to leave this page?',
                    showCancelButton: true,
                    confirmButtonText: 'Yes, Leave',
                    cancelButtonText: 'Stay',
                    confirmButtonColor: '#e11d48',
                    background: isDarkMode ? '#1e293b' : '#ffffff',
                    color: isDarkMode ? '#f8fafc' : '#334155',
                    backdrop: `rgba(0,0,0,0.7)`
                }).then((result) => {
                    if (result.isConfirmed) {
                        bypassDirty(); // Clear the warning flag
                        window.location.href = link.href; // Safely send them to the link they clicked
                    }
                });
            }
        });

        // 4. Track typing in textboxes
        window.onload = function () {
            // Find all textboxes with the 'dirty-track' class
            var inputs = document.querySelectorAll('.dirty-track');
            inputs.forEach(function (input) {
                // If the user types anything, mark the form as dirty
                input.addEventListener('input', markAsDirty);
            });
        };

        // 5. Custom Discard Confirmation (Now with SweetAlert!)
        function checkDiscard(e) {
            if (isDirty) {
                e.preventDefault(); // Stop the button from clicking immediately

                var isDarkMode = document.body.getAttribute("data-theme") === "dark";
                Swal.fire({
                    icon: 'warning',
                    title: 'Unsaved Changes',
                    text: 'You have unsaved changes. Are you sure you want to discard them?',
                    showCancelButton: true,
                    confirmButtonText: 'Yes, Discard',
                    cancelButtonText: 'Cancel',
                    confirmButtonColor: '#e11d48',
                    background: isDarkMode ? '#1e293b' : '#ffffff',
                    color: isDarkMode ? '#f8fafc' : '#334155',
                    backdrop: `rgba(0,0,0,0.7)`
                }).then((result) => {
                    if (result.isConfirmed) {
                        bypassDirty(); // Disable the browser warning
                        __doPostBack('<%= btnDiscard.UniqueID %>', ''); // Trigger C# code
                    }
                });
                return false;
            }

            bypassDirty();
            return true;
        }

        // 6. Real-Time Password Matching using existing lblMsg
        window.addEventListener('DOMContentLoaded', function () {
            var txtNew = document.getElementById('<%= txtNewPass.ClientID %>');
            var txtConfirm = document.getElementById('<%= txtConfirmPass.ClientID %>');
            var msgLabel = document.getElementById('<%= lblMsg.ClientID %>');

            function checkPasswords() {
                var val1 = txtNew.value;
                var val2 = txtConfirm.value;

                // If both are empty, clear the text
                if (val1 === "" && val2 === "") {
                    // Only clear it if it's currently showing a password message 
                    // (so we don't accidentally erase a backend success message)
                    if (msgLabel.innerHTML.includes('Passwords')) {
                        msgLabel.innerHTML = "";
                    }
                }
                // If they match, show green text
                else if (val1 === val2) {
                    msgLabel.innerHTML = "<i class='fas fa-check-circle'></i> Passwords match.";
                    msgLabel.className = "lbl-message text-success"; // Uses your existing green class
                }
                // If they don't match, show red text
                else {
                    msgLabel.innerHTML = "<i class='fas fa-times-circle'></i> Passwords do not match.";
                    msgLabel.className = "lbl-message text-error"; // Uses your existing red class
                }
            }

            // Listen for typing in both boxes
            if (txtNew && txtConfirm) {
                txtNew.addEventListener('input', checkPasswords);
                txtConfirm.addEventListener('input', checkPasswords);
            }
        });
    </script>

</asp:Content>
