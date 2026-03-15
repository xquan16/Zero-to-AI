<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EditorEditQuiz.aspx.cs" Inherits="Zero_to_AI.Editor.EditorEditQuiz" Async="true" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="editor-container">
        
        <div class="filter-bar">
            <span class="filter-label">Select Quiz to Edit:</span>
            <asp:DropDownList ID="ddlQuizzes" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlQuizzes_SelectedIndexChanged" CssClass="form-input" style="width:auto;">
            </asp:DropDownList>
        </div>

        <asp:Repeater ID="rptEditor" runat="server" OnItemCommand="rptEditor_ItemCommand">
            <ItemTemplate>
                <div class="question-block">
                    <div class="q-header">
                        <div class="q-title">
                            <%# Container.ItemIndex + 1 %>. <%# Eval("QuestionText") %>
                        </div>
                        <div class="q-meta">Marks: <%# Eval("Marks") %></div>
                    </div>

                    <div class="option-list">
                        <div class="option-item <%# Eval("CorrectAnswer").ToString() == "A" ? "correct-ans" : "" %>">A: <%# Eval("OptionA") %></div>
                        <div class="option-item <%# Eval("CorrectAnswer").ToString() == "B" ? "correct-ans" : "" %>">B: <%# Eval("OptionB") %></div>
                        <div class="option-item <%# Eval("CorrectAnswer").ToString() == "C" ? "correct-ans" : "" %>">C: <%# Eval("OptionC") %></div>
                        <div class="option-item <%# Eval("CorrectAnswer").ToString() == "D" ? "correct-ans" : "" %>">D: <%# Eval("OptionD") %></div>
                    </div>

                    <div style="text-align: right;">
                        <asp:Button ID="btnDelete" runat="server" Text="🗑 Delete Question" 
                            CommandName="DeleteQuestion" CommandArgument='<%# Eval("QuestionID") %>' 
                            CssClass="btn-delete" OnClientClick="return confirm('Are you sure you want to delete this?');" />
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Label ID="lblNoData" runat="server" Text="No questions found in this quiz." Visible="false" ForeColor="Red"></asp:Label>


        <div class="add-section">
            <div class="add-title">Add New Question</div>

            <div class="ai-panel">
                <div class="ai-title">✨ AI Question Copilot</div>
                <div class="ai-input-group">
                    <asp:TextBox ID="txtAITopic" runat="server" placeholder="Enter a topic (e.g., Neural Networks, Arduino)..." CssClass="form-input" style="flex: 1; border: none;"></asp:TextBox>
                    <asp:Button ID="btnGenerateAI" runat="server" Text="Generate" OnClick="btnGenerateAI_Click" CssClass="btn-ai" />
                </div>
                <asp:Label ID="lblAIStatus" runat="server" style="display: block; margin-top: 10px; font-size: 14px; font-weight: bold;"></asp:Label>
            </div>

            <div class="form-row" style="margin-bottom: 20px;">
                <span class="form-label">Question Text:</span>
                <asp:TextBox ID="txtNewQuestion" runat="server" CssClass="form-input" TextMode="MultiLine" Rows="3" placeholder="Enter the main question here..."></asp:TextBox>
            </div>

            <div class="form-grid">
                <div class="form-row">
                    <span class="form-label">Option A:</span>
                    <asp:TextBox ID="txtOptA" runat="server" CssClass="form-input"></asp:TextBox>
                </div>
                <div class="form-row">
                    <span class="form-label">Option B:</span>
                    <asp:TextBox ID="txtOptB" runat="server" CssClass="form-input"></asp:TextBox>
                </div>
                <div class="form-row">
                    <span class="form-label">Option C:</span>
                    <asp:TextBox ID="txtOptC" runat="server" CssClass="form-input"></asp:TextBox>
                </div>
                <div class="form-row">
                    <span class="form-label">Option D:</span>
                    <asp:TextBox ID="txtOptD" runat="server" CssClass="form-input"></asp:TextBox>
                </div>
            </div>

            <div class="form-grid">
                <div class="form-row">
                    <span class="form-label">Correct Answer:</span>
                    <asp:DropDownList ID="ddlCorrectAns" runat="server" CssClass="form-input">
                        <asp:ListItem Value="A">A</asp:ListItem>
                        <asp:ListItem Value="B">B</asp:ListItem>
                        <asp:ListItem Value="C">C</asp:ListItem>
                        <asp:ListItem Value="D">D</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-row">
                    <span class="form-label">Marks:</span>
                    <asp:TextBox ID="txtMarks" runat="server" CssClass="form-input" TextMode="Number" Text="10"></asp:TextBox>
                </div>
            </div>

            <asp:Button ID="btnAdd" runat="server" Text="Add Question to Database" CssClass="btn-add" OnClick="btnAdd_Click" />
            <br />
            <asp:Label ID="lblMsg" runat="server" Font-Bold="true"></asp:Label>
        </div>

    </div>
</asp:Content>
