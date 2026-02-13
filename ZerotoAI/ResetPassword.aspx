<%@ Page Title="" Language="C#" MasterPageFile="~/Auth.Master" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="Zero_to_AI.ZerotoAI.ResetPassword" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Reset Password</h2>

    <asp:Panel ID="pnlVerify" runat="server" Visible="true">
        <p class="auth-footer-text">Enter your username and email to verify identity.</p>

        <div class="form-group">
            <asp:Label ID="lblUser" runat="server" Text="Username"></asp:Label>
            <asp:TextBox ID="txtUserVerify" runat="server" CssClass="form-control" placeholder="Enter username"></asp:TextBox>
        </div>

        <div class="form-group">
            <asp:Label ID="lblEmail" runat="server" Text="Email Address"></asp:Label>
            <asp:TextBox ID="txtEmailVerify" runat="server" CssClass="form-control" TextMode="Email" placeholder="Enter registered email"></asp:TextBox>
            
            <div class="form-actions-split">
                <asp:Label ID="lblVerifyMsg" runat="server" CssClass="text-error" Visible="false"></asp:Label>
            </div>
        </div>

        <div class="form-group">
            <asp:Button ID="btnVerify" runat="server" Text="Verify & Continue" CssClass="btn-primary-full" OnClick="btnVerify_Click" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlReset" runat="server" Visible="false">
        <div style="background-color: #d1fae5; color: #065f46; padding: 10px; border-radius: 6px; margin-bottom: 15px; font-size: 0.9rem;">
            <i class="fas fa-check-circle"></i> Identity Verified. Set your new password.
        </div>

        <asp:HiddenField ID="hfResetUsername" runat="server" />

        <div class="form-group">
            <asp:Label ID="lblPass" runat="server" Text="New Password"></asp:Label>
            <asp:TextBox ID="txtNewPass" runat="server" CssClass="form-control" TextMode="Password" placeholder="New password"></asp:TextBox>
        </div>

        <div class="form-group">
            <asp:Label ID="lblConfirm" runat="server" Text="Confirm Password"></asp:Label>
            <asp:TextBox ID="txtConfirmPass" runat="server" CssClass="form-control" TextMode="Password" placeholder="Retype password"></asp:TextBox>

            <div class="form-actions-split">
                <asp:Label ID="lblResetMsg" runat="server" CssClass="text-error" Visible="false"></asp:Label>
            </div>
        </div>

        <div class="form-group">
            <asp:Button ID="btnReset" runat="server" Text="Update Password" CssClass="btn-primary-full" OnClick="btnReset_Click" />
        </div>
    </asp:Panel>

    <div class="auth-footer-text">
        Remembered it? <a href="Login.aspx">Back to Login</a>
    </div>

</asp:Content>
