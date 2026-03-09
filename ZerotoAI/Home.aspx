<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="ZerotoAI.Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="hero-section">

        <asp:Panel ID="pnlAdminBar" runat="server" Visible="false" CssClass="admin-edit-bar">
            <asp:Button ID="btnEditMode" runat="server" Text="✎ Edit Page" CssClass="btn-solid" OnClick="btnEditMode_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn-ghost btn-discard-custom" Visible="false" OnClick="btnCancel_Click" />
            <asp:Button ID="btnSaveChanges" runat="server" Text="💾 Save Changes" CssClass="btn-primary-full btn-save-custom" Visible="false" OnClick="btnSaveChanges_Click" />
        </asp:Panel>
        
        <h1 class="hero-title">
            <asp:Label ID="lblHeroTitle" runat="server"></asp:Label>
            <asp:TextBox ID="txtHeroTitle" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
        </h1>


        <p class="hero-subtitle">
            <asp:Label ID="lblHeroSubtitle" runat="server"></asp:Label>
            <asp:TextBox ID="txtHeroSubtitle" runat="server" CssClass="admin-edit-box" TextMode="MultiLine" Rows="3" Visible="false"></asp:TextBox>
        </p>
        
        <a href="Login.aspx" id="btnHeroCTA" runat="server" class="cta-button">
            <i class="fas fa-rocket"></i> <asp:Label ID="lblCtaText" runat="server"></asp:Label>
        </a>
        <asp:TextBox ID="txtCtaText" runat="server" CssClass="admin-edit-box cta-edit-modifier" Visible="false"></asp:TextBox>
    </div>

    <div class="content-sheet">
        
        <div class="about-container">
            <div class="about-text">
                <h2>
                    <asp:Label ID="lblAboutTitle" runat="server"></asp:Label>
                    <asp:TextBox ID="txtAboutTitle" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </h2>
                <p>
                    <asp:Label ID="lblAboutText" runat="server"></asp:Label>
                    <asp:TextBox ID="txtAboutText" runat="server" CssClass="admin-edit-box" TextMode="MultiLine" Rows="5" Visible="false"></asp:TextBox>
                </p>
            </div>
            <div class="about-image">
                <asp:Image ID="aboutLogo" runat="server" ImageUrl="~/images/logo.png" AlternateText="Zero to AI Logo" />
            </div>
        </div>

        <div class="features-grid">
            
            <div class="feature-card">
                <i class="fas fa-brain feature-icon"></i>
                <div class="feature-title">
                    <asp:Label ID="lblFeat1Title" runat="server"></asp:Label>
                    <asp:TextBox ID="txtFeat1Title" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </div>
                <div class="feature-desc">
                    <asp:Label ID="lblFeat1Desc" runat="server"></asp:Label>
                    <asp:TextBox ID="txtFeat1Desc" runat="server" CssClass="admin-edit-box" TextMode="MultiLine" Rows="3" Visible="false"></asp:TextBox>
                </div>
            </div>

            <div class="feature-card">
                <i class="fas fa-chart-pie feature-icon"></i>
                <div class="feature-title">
                    <asp:Label ID="lblFeat2Title" runat="server"></asp:Label>
                    <asp:TextBox ID="txtFeat2Title" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </div>
                <div class="feature-desc">
                    <asp:Label ID="lblFeat2Desc" runat="server"></asp:Label>
                    <asp:TextBox ID="txtFeat2Desc" runat="server" CssClass="admin-edit-box" TextMode="MultiLine" Rows="3" Visible="false"></asp:TextBox>
                </div>
            </div>

            <div class="feature-card">
                <i class="fas fa-laptop-code feature-icon"></i>
                <div class="feature-title">
                    <asp:Label ID="lblFeat3Title" runat="server"></asp:Label>
                    <asp:TextBox ID="txtFeat3Title" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </div>
                <div class="feature-desc">
                    <asp:Label ID="lblFeat3Desc" runat="server"></asp:Label>
                    <asp:TextBox ID="txtFeat3Desc" runat="server" CssClass="admin-edit-box" TextMode="MultiLine" Rows="3" Visible="false"></asp:TextBox>
                </div>
            </div>

        </div>

        <div class="stats-row">
            <div class="stat-item">
                <h2>
                    <asp:Label ID="lblStat1Num" runat="server"></asp:Label>
                    <asp:TextBox ID="txtStat1Num" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </h2>
                <div class="stat-desc">
                    <asp:Label ID="lblStat1Text" runat="server"></asp:Label>
                    <asp:TextBox ID="txtStat1Text" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </div>
            </div>
            
            <div class="stat-item">
                <h2>
                    <asp:Label ID="lblStat2Num" runat="server"></asp:Label>
                    <asp:TextBox ID="txtStat2Num" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </h2>
                <div class="stat-desc">
                    <asp:Label ID="lblStat2Text" runat="server"></asp:Label>
                    <asp:TextBox ID="txtStat2Text" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </div>
            </div>
            
            <div class="stat-item">
                <h2>
                    <asp:Label ID="lblStat3Num" runat="server"></asp:Label>
                    <asp:TextBox ID="txtStat3Num" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </h2>
                <div class="stat-desc">
                    <asp:Label ID="lblStat3Text" runat="server"></asp:Label>
                    <asp:TextBox ID="txtStat3Text" runat="server" CssClass="admin-edit-box" Visible="false"></asp:TextBox>
                </div>
            </div>
        </div>
    </div>
</asp:Content>