<%@ Page Title="" Language="C#" MasterPageFile="~/Auth.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ZerotoAI.Login" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Welcome Back</h2>
    
    <div class="form-group">
        <asp:Label ID="userLbl" runat="server" Text="Username"></asp:Label>
        <asp:TextBox ID="userTxt" runat="server" CssClass="form-control" placeholder="Enter username"></asp:TextBox>
    </div>

    <div class="form-group">
        <asp:Label ID="passLbl" runat="server" Text="Password"></asp:Label>
        <asp:TextBox ID="passTxt" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••"></asp:TextBox>
    </div>

    <asp:Label ID="errorLbl" runat="server" ForeColor="#ff4757" Visible="false" style="display:block; margin-bottom:10px;"></asp:Label>

    <div class="form-group">
        <asp:Button ID="loginBtn" runat="server" Text="Sign In" CssClass="btn-primary-full" OnClick="loginBtn_Click" />
    </div>

    <div class="auth-footer-text">
        Don't have an account? 
        <asp:HyperLink ID="signupLink" runat="server" NavigateUrl="~/ZerotoAI/Signup.aspx">Sign Up</asp:HyperLink>
    </div>

</asp:Content>
