<%@ Page Title="" Language="C#" MasterPageFile="~/Auth.Master" AutoEventWireup="true" CodeBehind="Signup.aspx.cs" Inherits="ZerotoAI.Signup" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Create Account</h2>

    <div class="form-row-split">
        <div class="form-group">
            <asp:Label ID="fnameLbl" runat="server" Text="First Name"></asp:Label>
            <asp:TextBox ID="fnameTxt" runat="server" CssClass="form-control" placeholder="Xxx"></asp:TextBox>
        </div>
        <div class="form-group">
            <asp:Label ID="lnameLbl" runat="server" Text="Last Name"></asp:Label>
            <asp:TextBox ID="lnameTxt" runat="server" CssClass="form-control" placeholder="Xxx"></asp:TextBox>
        </div>
    </div>

    <div class="form-group">
        <asp:Label ID="emailLbl" runat="server" Text="Email Address"></asp:Label>
        <asp:TextBox ID="emailTxt" runat="server" CssClass="form-control" TextMode="Email" placeholder="xxx@example.com"></asp:TextBox>
    </div>

    <div class="form-group">
        <asp:Label ID="userLbl" runat="server" Text="Username"></asp:Label>
        <asp:TextBox ID="userTxt" runat="server" CssClass="form-control" placeholder="Choose a username"></asp:TextBox>
    </div>

    <div class="form-group">
        <asp:Label ID="passLbl" runat="server" Text="Password"></asp:Label>
        <asp:TextBox ID="passTxt" runat="server" CssClass="form-control" TextMode="Password" placeholder="••••••••"></asp:TextBox>
        
        <div class="form-actions-split">
            <asp:Label ID="msgLbl" runat="server" CssClass="text-error" Visible="false"></asp:Label>
        </div>
    </div>

    <div class="form-group">
        <asp:Button ID="signupBtn" runat="server" Text="Create Account" CssClass="btn-primary-full" OnClick="signupBtn_Click" />
    </div>

    <div class="auth-footer-text">
        Already have an account? 
        <asp:HyperLink ID="loginLink" runat="server" NavigateUrl="~/ZerotoAI/Login.aspx">Sign In</asp:HyperLink>
    </div>

</asp:Content>
