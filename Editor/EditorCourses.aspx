<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EditorCourses.aspx.cs" Inherits="Zero_to_AI.Editor.EditorCourses" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:MultiView ID="MainMultiView" runat="server" ActiveViewIndex="0">

        <!-- ═══════════════════════ VIEW 0: DASHBOARD ═══════════════════════ -->
        <asp:View ID="ViewDashboard" runat="server">

            <div class="editor-hero">
                <h1><i class="fas fa-edit" style="margin-right:10px"></i>Manage Content</h1>
                <p>Edit articles, manage quiz questions, and control content status.</p>
            </div>

            <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert-box"></asp:Label>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="filter-tabs">
                    <button class="filter-tab active" data-filter="all"    onclick="filterSec('all',this)">All</button>
                    <button class="filter-tab"         data-filter="ml"    onclick="filterSec('ml',this)"><i class="fas fa-brain"></i> Machine Learning</button>
                    <button class="filter-tab"         data-filter="robot" onclick="filterSec('robot',this)"><i class="fas fa-microchip"></i> Robotics</button>
                </div>
                <asp:LinkButton ID="btnAddNew" runat="server" CssClass="btn-add-new" OnClick="btnAddNew_Click">
                    <i class="fas fa-plus"></i> Add New Article
                </asp:LinkButton>
            </div>

            <!-- Machine Learning -->
            <div id="sec-ml" class="mb-4">
                <div class="sec-header">
                    <div class="sec-icon ml"><i class="fas fa-brain"></i></div>
                    <h3>Machine Learning</h3>
                    <div class="sec-divider"></div>
                </div>
                <div class="row g-3">
                    <asp:Repeater ID="rptML" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="course-card">
                                    <span class='status-badge <%# GetBadgeClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                                    <div class="card-banner banner-ml">
                                        <i class="fas <%# Eval("ImageURL") %>"></i>
                                    </div>
                                    <div class="card-body">
                                        <div class="card-title"><%# Eval("Title") %></div>
                                        <div class="card-desc"><%# Eval("Description") %></div>
                                        <div class="btn-grid">
                                            <asp:LinkButton runat="server" CommandName="EditArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-edit"><i class="fas fa-pen"></i> Edit Article</asp:LinkButton>
                                            <asp:LinkButton runat="server" CommandName="DeleteArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-del" OnClientClick="return confirm('Delete this article?');"><i class="fas fa-trash"></i></asp:LinkButton>
                                        </div>
                                        <asp:LinkButton runat="server" CommandName="ManageQuiz" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-quiz"><i class="fas fa-question-circle"></i> Manage Quiz Questions</asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Robotics -->
            <div id="sec-robot">
                <div class="sec-header">
                    <div class="sec-icon robot"><i class="fas fa-microchip"></i></div>
                    <h3>Robotics</h3>
                    <div class="sec-divider"></div>
                </div>
                <div class="row g-3">
                    <asp:Repeater ID="rptRobot" runat="server" OnItemCommand="rptCourses_ItemCommand">
                        <ItemTemplate>
                            <div class="col-12 col-sm-6 col-lg-3">
                                <div class="course-card">
                                    <span class='status-badge <%# GetBadgeClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                                    <div class="card-banner banner-robot">
                                        <i class="fas <%# Eval("ImageURL") %>"></i>
                                    </div>
                                    <div class="card-body">
                                        <div class="card-title"><%# Eval("Title") %></div>
                                        <div class="card-desc"><%# Eval("Description") %></div>
                                        <div class="btn-grid">
                                            <asp:LinkButton runat="server" CommandName="EditArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-edit"><i class="fas fa-pen"></i> Edit Article</asp:LinkButton>
                                            <asp:LinkButton runat="server" CommandName="DeleteArticle" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-del" OnClientClick="return confirm('Delete this article?');"><i class="fas fa-trash"></i></asp:LinkButton>
                                        </div>
                                        <asp:LinkButton runat="server" CommandName="ManageQuiz" CommandArgument='<%# Eval("ArticleID") %>' CssClass="btn-quiz"><i class="fas fa-question-circle"></i> Manage Quiz Questions</asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

        </asp:View>

        <!-- ═══════════════════════ VIEW 1: EDIT ARTICLE ═══════════════════════ -->
        <asp:View ID="ViewEditArticle" runat="server">

            <asp:LinkButton ID="btnBackFromEdit" runat="server" OnClick="btnBack_Click" CssClass="btn-back" CausesValidation="false">
                <i class="fas fa-arrow-left"></i> Back
            </asp:LinkButton>

            <asp:Label ID="lblEditMsg" runat="server" Visible="false" CssClass="alert-box"></asp:Label>

            <div class="form-panel">
                <h3><i class="fas fa-edit"></i> <asp:Label ID="lblFormTitle" runat="server" Text="Edit Article"></asp:Label></h3>

                <asp:HiddenField ID="hfArticleID" runat="server" />

                <div class="row">
                    <div class="col-md-8">
                        <div class="form-group">
                            <label>Article Title</label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="e.g., 1. Intro to AI Concepts"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle" ErrorMessage="Title is required." ForeColor="Red" Display="Dynamic" ValidationGroup="ArticleForm" />
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label>Status</label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Published"   Value="Published"></asp:ListItem>
                                <asp:ListItem Text="Draft"       Value="Draft"></asp:ListItem>
                                <asp:ListItem Text="Unpublished" Value="Unpublished"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Category</label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Machine Learning" Value="Machine Learning"></asp:ListItem>
                                <asp:ListItem Text="Robotics"         Value="Robotics"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label>Icon (FontAwesome class, e.g. fa-brain)</label>
                            <asp:TextBox ID="txtIcon" runat="server" CssClass="form-control" placeholder="fa-brain"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label>Short Description <small style="font-weight:400;color:var(--text-muted)">(shown on the card — use | to separate key takeaways)</small></label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="e.g. Understand what AI is|Key branches of AI|Real-world applications"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Full Learning Content <small style="font-weight:400;color:var(--text-muted)">(HTML allowed)</small></label>
                    <asp:TextBox ID="txtContent" runat="server" CssClass="content-textarea" TextMode="MultiLine" placeholder="<h2>Topic</h2><p>Start writing...</p>"></asp:TextBox>
                </div>

                <div class="d-flex justify-content-end">
                    <asp:Button ID="btnSaveArticle" runat="server" Text="Save Article" CssClass="btn-save" OnClick="btnSaveArticle_Click" ValidationGroup="ArticleForm" />
                </div>
            </div>

        </asp:View>

        <!-- ═══════════════════════ VIEW 2: MANAGE QUIZ ═══════════════════════ -->
        <asp:View ID="ViewManageQuiz" runat="server">

            <asp:LinkButton ID="btnBackFromQuiz" runat="server" OnClick="btnBack_Click" CssClass="btn-back" CausesValidation="false">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </asp:LinkButton>

            <asp:Label ID="lblQuizMsg" runat="server" Visible="false" CssClass="alert-box"></asp:Label>

            <asp:HiddenField ID="hfQuizArticleID" runat="server" />
            <asp:HiddenField ID="hfQuizID"        runat="server" />
            <asp:HiddenField ID="hfEditQuestionID" runat="server" />

            <!-- Current Questions -->
            <div class="quiz-panel">
                <h4>
                    <i class="fas fa-question-circle"></i>
                    Quiz Questions — <asp:Label ID="lblQuizArticleTitle" runat="server"></asp:Label>
                </h4>

                <asp:Repeater ID="rptQuestions" runat="server" OnItemCommand="rptQuestions_ItemCommand">
                    <ItemTemplate>
                        <div class="q-card">
                            <div class="q-text"><%# Eval("QuestionText") %></div>
                            <div class="q-opts">
                                <span><strong>A.</strong> <%# Eval("OptionA") %></span>
                                <span><strong>B.</strong> <%# Eval("OptionB") %></span>
                                <span><strong>C.</strong> <%# Eval("OptionC") %></span>
                                <span><strong>D.</strong> <%# Eval("OptionD") %></span>
                            </div>
                            <span class="correct-badge">✓ Answer: <%# Eval("CorrectAnswer") %></span>
                            <div class="q-actions">
                                <asp:LinkButton runat="server" CommandName="EditQuestion" CommandArgument='<%# Eval("QuestionID") %>' CssClass="btn-q-edit"><i class="fas fa-pen"></i> Edit</asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="DeleteQuestion" CommandArgument='<%# Eval("QuestionID") %>' CssClass="btn-q-del" OnClientClick="return confirm('Delete this question?');"><i class="fas fa-trash"></i> Delete</asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Label ID="lblNoQuestions" runat="server" Visible="false">
                    <div class="no-quiz-msg"><i class="fas fa-inbox"></i>No questions yet. Add one below.</div>
                </asp:Label>

                <!-- Add / Edit Question Form -->
                <div class="add-q-form">
                    <h5><i class="fas fa-plus-circle"></i> <asp:Label ID="lblQFormTitle" runat="server" Text="Add New Question"></asp:Label></h5>

                    <div class="form-group">
                        <label>Question Text</label>
                        <asp:TextBox ID="txtQText" runat="server" CssClass="form-control" placeholder="e.g. What does AI stand for?" TextMode="MultiLine" Rows="2"></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQText" ErrorMessage="Question text is required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
                    </div>

                    <div class="opts-grid">
                        <div class="form-group">
                            <label>Option A</label>
                            <asp:TextBox ID="txtOptA" runat="server" CssClass="form-control" placeholder="Option A"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtOptA" ErrorMessage="Required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
                        </div>
                        <div class="form-group">
                            <label>Option B</label>
                            <asp:TextBox ID="txtOptB" runat="server" CssClass="form-control" placeholder="Option B"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtOptB" ErrorMessage="Required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
                        </div>
                        <div class="form-group">
                            <label>Option C</label>
                            <asp:TextBox ID="txtOptC" runat="server" CssClass="form-control" placeholder="Option C"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtOptC" ErrorMessage="Required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
                        </div>
                        <div class="form-group">
                            <label>Option D</label>
                            <asp:TextBox ID="txtOptD" runat="server" CssClass="form-control" placeholder="Option D"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtOptD" ErrorMessage="Required." ForeColor="Red" Display="Dynamic" ValidationGroup="QuizForm" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Correct Answer</label>
                        <asp:DropDownList ID="ddlCorrect" runat="server" CssClass="form-control" style="max-width:120px;">
                            <asp:ListItem Text="A" Value="A"></asp:ListItem>
                            <asp:ListItem Text="B" Value="B"></asp:ListItem>
                            <asp:ListItem Text="C" Value="C"></asp:ListItem>
                            <asp:ListItem Text="D" Value="D"></asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <asp:Button ID="btnSaveQuestion" runat="server" CssClass="btn-add-q" OnClick="btnSaveQuestion_Click" ValidationGroup="QuizForm" Text="Save Question" />
                </div>
            </div>

        </asp:View>

    </asp:MultiView>

    <script>
        function filterSec(cat, btn) {
            localStorage.setItem('editorFilter', cat);
            applyEditorFilter(cat);
            document.querySelectorAll('.filter-tab').forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');
        }

        function applyEditorFilter(cat) {
            var ml = document.getElementById('sec-ml');
            var robot = document.getElementById('sec-robot');
            if (!ml || !robot) return;
            ml.style.display = (cat === 'robot') ? 'none' : 'block';
            robot.style.display = (cat === 'ml') ? 'none' : 'block';
        }

        // Restore filter on every page load / postback
        window.addEventListener('DOMContentLoaded', function () {
            var saved = localStorage.getItem('editorFilter') || 'all';
            applyEditorFilter(saved);
            document.querySelectorAll('.filter-tab').forEach(function (b) {
                b.classList.remove('active');
                if (b.getAttribute('data-filter') === saved) b.classList.add('active');
            });
        });
    </script>

</asp:Content>

