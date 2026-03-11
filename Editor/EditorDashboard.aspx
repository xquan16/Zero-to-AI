<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EditorDashboard.aspx.cs" Inherits="Zero_to_AI.Editor.EditorDashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dash-wrap">
        <div class="dash-header">
            <h1><asp:Label ID="lblWelcome" runat="server" Text="Creator Workspace"></asp:Label></h1>
        </div>

        <div class="stat-grid">
            <a href="EditorSimulations.aspx" class="stat-card">
                <div class="stat-icon purple"><i class="fas fa-vr-cardboard"></i></div>
                <div class="stat-info"><h3 class="big-num"><asp:Label ID="lblEdSimTotal" runat="server">0</asp:Label></h3><span>Simulations Managed</span></div>
            </a>
            <a href="EditorCourses.aspx" class="stat-card">
                <div class="stat-icon blue"><i class="fas fa-file-alt"></i></div>
                <div class="stat-info"><h3 class="big-num"><asp:Label ID="lblEdPublished" runat="server">0</asp:Label></h3><span>Articles Published</span></div>
            </a>
            <a href="EditorEditQuiz.aspx" class="stat-card">
                <div class="stat-icon teal"><i class="fas fa-question-circle"></i></div>
                <div class="stat-info"><h3 class="big-num"><asp:Label ID="lblEdQuestions" runat="server">0</asp:Label></h3><span>Questions Managed</span></div>
            </a>
        </div>

        <div class="panel">
            <h2><i class="fas fa-bolt"></i> Quick Actions</h2>
            <a href="EditorCourses.aspx" class="btn-action"><i class="fas fa-plus"></i> Create New Article</a>
            <a href="EditorEditQuiz.aspx" class="btn-action" style="background: #0ea5e9;"><i class="fas fa-list-check"></i> Manage Quizzes</a>
        </div>

        <div class="panel">
            <h2><i class="fas fa-history"></i> My Recent Activity</h2>
            <asp:GridView ID="gvEdLogs" runat="server" AutoGenerateColumns="false" 
                CssClass="admin-grid-table" Width="100%" GridLines="None" CellPadding="10">
                <HeaderStyle CssClass="grid-header" HorizontalAlign="Left" />
                <Columns>
                    <asp:BoundField DataField="ActionType" HeaderText="Action" ItemStyle-Font-Bold="true" ItemStyle-ForeColor="#7c3aed" />
                    <asp:BoundField DataField="ActionDetails" HeaderText="Details" />
                    <asp:BoundField DataField="ActionDate" HeaderText="Date" DataFormatString="{0:MMM dd HH:mm}" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
