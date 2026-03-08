<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MemberSelectQuizTopic.aspx.cs" Inherits="Zero_to_AI.Member.MemberSelectQuizTopic" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="topic-page-container">
        <div class="page-title">Select a Topic</div>
        <div class="page-subtitle">Choose a domain to challenge your skills</div>

        <div class="cards-wrapper">
            <a href="MemberQuiz.aspx?topic=ML" class="topic-card border-blue">
                <div class="icon-circle">🧠</div>
                <div class="card-title">Machine Learning</div>
                <div class="card-desc">Dive into AI concepts, neural networks, and Python libraries.</div>
            </a>

            <a href="MemberQuiz.aspx?topic=Robo" class="topic-card border-red">
                <div class="icon-circle">🤖</div>
                <div class="card-title">Robotics</div>
                <div class="card-desc">Explore automation, sensors, and mechanical design.</div>
            </a>

            <a href="MemberQuiz.aspx?topic=All" class="topic-card border-green">
                <div class="icon-circle">🔥</div>
                <div class="card-title">Mixed Challenge</div>
                <div class="card-desc">Ready for the ultimate test? Mix questions from both domains!</div>
            </a>
        </div>

        <div class="history-section">
            <h3 class="history-title">📜 My Quiz History</h3>
            
            <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False" 
                CssClass="quiz-history-grid" GridLines="None"> 
                <Columns>
                    <asp:BoundField DataField="Title" HeaderText="Quiz Name" />
                    <asp:BoundField DataField="Score" HeaderText="Score" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                    <asp:BoundField DataField="CompletedDate" HeaderText="Date Taken" DataFormatString="{0:MMM dd, yyyy HH:mm}" ItemStyle-HorizontalAlign="Center" HeaderStyle-HorizontalAlign="Center" />
                </Columns>
            </asp:GridView>
            
            <asp:Label ID="lblNoHistory" runat="server" Text="You haven't taken any quizzes yet. Start one above!" 
                Visible="false" CssClass="no-history-msg"></asp:Label>
        </div>
    </div>
</asp:Content>
