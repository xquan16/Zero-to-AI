<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EditProfile.aspx.cs" Inherits="Zero_to_AI.ZerotoAI.EditProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField ID="hfCroppedImage" runat="server" />
    <asp:HiddenField ID="hfOriginalFileName" runat="server" />
    <div class="profile-full-container">
        
        <div class="profile-left-pane">
            
            <asp:Image ID="imgPreview" runat="server" CssClass="avatar-preview-large" ImageUrl="~/images/default_user.png" />

            <div class="upload-area">
                <asp:FileUpload ID="fuProfilePic" runat="server" CssClass="file-upload-control" onchange="markAsDirty(); previewImage(this);" BorderColor="#999999" BorderStyle="Inset" />
                <small style="opacity: 0.7; margin-top:5px;">PNG or JPG only</small>
            </div>

        </div>

        <div id="cropModal" class="crop-modal">
            <div class="crop-container">
                <div class="crop-image-wrapper">
                    <img id="imgToCrop" src="" alt="Image to crop" />
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

            <h4 style="color:var(--text-muted); margin:40px 0 20px;">Security</h4>

            <div class="form-group">
                <label>Username</label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control dirty-track"></asp:TextBox>
                <small style="color:var(--text-muted);">Note: Changing this will require you to login again.</small>
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

            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="lbl-message"></asp:Label>

            <div class="form-actions-right">
                <asp:Button ID="btnDiscard" runat="server" Text="Discard" 
                    CssClass="btn-ghost btn-discard-custom" 
                    OnClick="btnDiscard_Click" OnClientClick="bypassDirty();" />
                
                <asp:Button ID="btnSave" runat="server" Text="Save Changes" 
                    CssClass="btn-primary-full btn-save-custom" 
                    OnClick="btnSave_Click" OnClientClick="bypassDirty();" />
            </div>

        </div>
    </div>

    <script type="text/javascript">
        var cropper;
        var fileInput = document.getElementById('<%= fuProfilePic.ClientID %>');
        var cropModal = document.getElementById('cropModal');
        var imgToCrop = document.getElementById('imgToCrop');
        var hfCropped = document.getElementById('<%= hfCroppedImage.ClientID %>');
        var hfOriginal = document.getElementById('<%= hfOriginalFileName.ClientID %>');
        var imgPreview = document.getElementById('<%= imgPreview.ClientID %>');
        var isDirty = false;

        // 1. When user selects a file (also used by inline onchange previewImage)
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

        if (fileInput) {
            fileInput.addEventListener('change', function (e) {
                var files = e.target.files;
                if (files && files.length > 0) {
                    handleFileSelection(files[0]);
                    // Clear input so same file can be selected again if cancelled
                    fileInput.value = '';
                }
            });
        }

        // helper used by markup onchange
        function previewImage(input) {
            if (!input || !input.files || input.files.length === 0) return;
            handleFileSelection(input.files[0]);
            // clear the input so same file can be reselected later
            try { input.value = ''; } catch (ex) { }
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
        window.onbeforeunload = function (e) {
            if (isDirty) return "You have unsaved changes.";
        };
    </script>

</asp:Content>
