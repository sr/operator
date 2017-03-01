(function ($, BAMBOO) {
    BAMBOO.GITHUBENTERPRISE = {};

    /**
     * GitHub Repository form
     * @param {Object} opts - options with which to set up the form
     * @constructor
     */
    function RepositoryForm(opts) {
        var defaults = {
                repositoryKey: null,
                repositoryId: 0,
                selectors: {
                    repositoryType: null,
                    username: null,
                    password: null,
                    loadRepositoriesButton: null,
                    repository: null,
                    branch: null
                }
            },
            options = $.extend(true, defaults, opts);

        // Values
        this.repositoryKey = options.repositoryKey;
        this.repositoryId = options.repositoryId;

        // jqXHR objects for repository/branch retrieval
        this._jqXHRRepository = null;
        this._jqXHRBranch = null;

        // Form controls
        this._$fieldset = $("fieldset#repository-edit-" + BAMBOO.escapeIdToJQuerySelector(options.repositoryKey));
        this.$repositoryType = $(options.selectors.repositoryType);
        this.$username = this._$fieldset.find(options.selectors.username);
        this.$password = this._$fieldset.find(options.selectors.password);
        this.$loadRepositoriesButton = this._$fieldset.find(options.selectors.loadRepositoriesButton);
        this.$repository = this._$fieldset.find(options.selectors.repository);
        this.$branch = this._$fieldset.find(options.selectors.branch);
    }

    RepositoryForm.prototype = {
        init: function () {
            // Attach handlers
            this.$loadRepositoriesButton.click(_.bind(this.loadRepositoriesClick, this));
            this.$repository.change(_.bind(this.repositoryChange, this));

            // Load repository list on load
            if (this.$repositoryType.val() == this.repositoryKey && (this.repositoryId || (this.$username.val() && this.$password.val()))) {
                this.loadRepositories();

                if (this.$repository.val() !== null) {
                    this.loadBranches();
                }
            }
        },
        loadRepositoriesClick: function () {
            this.clearFieldErrors();
            this.$repository.prop('disabled', true);
            this.$branch.prop('disabled', true);
            if (this._jqXHRBranch) { this._jqXHRBranch.abort(); }
            this.loadRepositories().done(_.bind(function (json) {
                var repositories = json['repositories'];

                if (json['status'] == "OK" && repositories && repositories.length) {
                    this.$repository.focus();
                    if (!this.$branch.children().length) {
                        this.$branch.append(this.generateBranchOption(this.defaultBranch()));
                    }

                    // select first repository by default
                    this.$repository.val(this.$repository.find('option:first').val());

                    this.loadBranches();
                }
            }, this));
        },
        repositoryChange: function () {
            this.clearFieldErrors();
            this.$branch.prop('disabled', true).empty().append(this.generateBranchOption(this.defaultBranch()));
            this.loadBranches();
        },
        loadRepositories: function () {
            var $repository = this.$repository,
                $loadingOptgroup = $('<optgroup />').attr('label', AJS.I18n.getText('repository.github.loadingRepositories')).appendTo($repository),
                currentlySelected = $repository.val(),
                generateRepositoryOption = this.generateRepositoryOption,
                update = _.bind(function (json, textStatus, jqXHR) {
                    var $list = document.createDocumentFragment(),
                        repositories = json['repositories'];

                    if (json['status'] == "OK" && repositories && repositories.length) {
                        $.each(repositories, function () {
                            $list.appendChild(generateRepositoryOption(this).get(0));
                        });

                        $repository.empty().prop('disabled', false).get(0).appendChild($list);
                        $repository.val(currentlySelected);
                    } else {
                        showError(jqXHR);
                    }
                }, this),
                restore = _.bind(function () {
                    $loadingOptgroup.remove();
                    this.$loadRepositoriesButton.prop('disabled', false);
                }, this),
                showError = _.bind(function (jqXHR) {
                    var response, errors = [], repositories;

                    if (jqXHR.statusText != 'abort') {
                        try {
                            response = $.parseJSON(jqXHR.responseText);
                            errors = response['errors'] || [];
                            repositories = response['repositories'];
                        }
                        catch (e) {}

                        if (repositories && !repositories.length) {
                            errors.push(AJS.I18n.getText('repository.github.error.noRepositories').replace('{0}', this.$username.val()));
                        }
                        if (!errors.length) {
                            errors.push(AJS.I18n.getText('repository.github.ajaxError') + '[' + jqXHR.status + ' ' + jqXHR.statusText + ']');
                        }
                        this.addFieldErrors(this.$repository, errors);
                    }
                }, this);

            this.$loadRepositoriesButton.prop('disabled', true);
            return this.getRepositoryList().done(update).fail(showError).always(restore);
        },
        generateRepositoryOption: function (repository) {
            return $('<option/>', {
                text: repository['full_name'],
                val: repository['full_name'],
                data: repository
            });
        },
        loadBranches: function () {
            var $branch = this.$branch,
                $loadingOptgroup = $('<optgroup />').attr('label', AJS.I18n.getText('repository.github.loadingBranches')).appendTo($branch),
                $container = $branch.closest('.field-group'),
                currentlySelected = $branch.val(),
                generateBranchOption = this.generateBranchOption,
                update = _.bind(function (json, textStatus, jqXHR) {
                    var $list = $(),
                        branches = json['branches'];

                    if (json['status'] == "OK" && branches) {
                        $.each(branches, function () {
                            $list = $list.add(generateBranchOption(this['name']));
                        });
                        $branch.empty().append($list).prop('disabled', false).val(currentlySelected);
                        if (currentlySelected && $branch.val() != currentlySelected) {
                            $branch.val(this.defaultBranch());
                        }
                    } else {
                        showError(jqXHR);
                    }
                }, this),
                restore = _.bind(function () { $loadingOptgroup.remove(); }, this),
                showError = _.bind(function (jqXHR) {
                    var response, errors = [];

                    if (jqXHR.statusText != 'abort') {
                        try {
                            response = $.parseJSON(jqXHR.responseText);
                            errors = response['errors'] || [];
                        }
                        catch (e) {}

                        if (!errors.length) {
                            errors.push(AJS.I18n.getText('repository.github.ajaxError') + '[' + jqXHR.status + ' ' + jqXHR.statusText + ']');
                        }
                        this.addFieldErrors(this.$branch, errors);
                    }
                }, this);

            // Show branches field if it was hidden
            if ($container.hasClass('hidden')) {
                $container.hide().removeClass('hidden').slideDown();
            }
            return this.getBranchList(this.$repository.val()).done(update).fail(showError).always(restore);
        },
        generateBranchOption: function (branch) {
            return $('<option/>', { text: branch });
        },
        defaultBranch: function () {
            return 'master';
        },
        getJsonResponse: function (url, data, jqXHR, $field) {
            var $container = $field.closest('.field-group'),
                loadingClass = 'loading';

            if (jqXHR) { jqXHR.abort(); }

            $container.addClass(loadingClass);

            return $.ajax({
                type: 'POST',
                url: url,
                data: JSON.stringify(data),
                contentType: 'application/json',
                processData: false,
                dataType: 'json'
            }).always(function () { $container.removeClass(loadingClass); });
        },
        getRepositoryList: function () {
            var url = AJS.contextPath() + '/rest/git/latest/gh/repositories/' + this.$username.val() + '/';

            return this._jqXHRRepository = this.getJsonResponse(url, {
                password: this.$password.val(),
                repositoryId: this.repositoryId
            }, this._jqXHRRepository, this.$repository);
        },
        getBranchList: function (repository) {
            var url = AJS.contextPath() + '/rest/git/latest/gh/repositories/' + repository + '/branches/';

            return this._jqXHRBranch = this.getJsonResponse(url, {
                username: this.$username.val(),
                password: this.$password.val(),
                repository: repository,
                repositoryId: this.repositoryId
            }, this._jqXHRBranch, this.$branch);
        },
        addFieldErrors: function ($field, errors) {
            BAMBOO.addFieldErrors($field.closest('form'), $field.attr('name'), errors, true);
        },
        clearFieldErrors: function () {
            this._$fieldset.find('.error').slideUp(function () { $(this).remove(); });
        }
    };

    BAMBOO.GITHUBENTERPRISE.RepositoryForm = RepositoryForm;
}(jQuery, window.BAMBOO = (window.BAMBOO || {})));