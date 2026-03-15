<%@ Page Title="" Language="C#" MasterPageFile="~/Auth.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ZerotoAI.Login" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlLoginForm" runat="server">
        <h2>Welcome Back</h2>

        <asp:Label ID="successLbl" runat="server" CssClass="text-success" Visible="false"></asp:Label>

        <div class="form-group">
            <asp:Label ID="userLbl" runat="server" Text="Username"></asp:Label>
            <asp:TextBox ID="userTxt" runat="server" CssClass="form-control" placeholder="Enter username"></asp:TextBox>
        </div>

        <div class="form-group">
            <asp:Label ID="passLbl" runat="server" Text="Password"></asp:Label>
            <asp:TextBox ID="passTxt" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••"></asp:TextBox>
            
            <div class="form-actions-split">
                <asp:Label ID="errorLbl" runat="server" CssClass="text-error" Visible="false"></asp:Label>
                <a href="ResetPassword.aspx" class="forgot-password-link">Forgot Password?</a>
            </div>
        </div>

        <div class="form-group">
            <asp:Button ID="loginBtn" runat="server" Text="Sign In" CssClass="btn-primary-full" OnClick="loginBtn_Click" />
        </div>

        <div class="auth-footer-text">
            Don't have an account? 
            <asp:HyperLink ID="signupLink" runat="server" NavigateUrl="~/ZerotoAI/Signup.aspx">Sign Up</asp:HyperLink>
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlBanned" runat="server" Visible="false">
        <h2 class="text-danger banned-header"><i class="fas fa-ban"></i> Account Suspended</h2>
        <p class="banned-desc">
            Your account has been restricted by an administrator. 
            If you believe this is a mistake, you may leave a message below.
        </p>

        <div class="form-group">
            <asp:TextBox ID="txtAppeal" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control appeal-textbox" placeholder="Explain your situation to the admin..."></asp:TextBox>         
        </div>

        <div class="form-group">
            <asp:Button ID="btnSubmitAppeal" runat="server" Text="Send Message to Admin" CssClass="btn-primary-full" OnClick="btnSubmitAppeal_Click" />
        </div>
        
        <asp:LinkButton ID="btnBackToLogin" runat="server" OnClick="btnBackToLogin_Click" CssClass="btn-back-link">
            <i class="fas fa-arrow-left"></i> Back to Login
        </asp:LinkButton>

        <asp:Label ID="lblAppealStatus" runat="server" CssClass="appeal-status"></asp:Label>
        
        <asp:HiddenField ID="hfBannedUserID" runat="server" />
    </asp:Panel>

</asp:Content>
