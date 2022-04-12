<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password') displayInfo=realm.password && realm.registrationAllowed && !registrationDisabled??; section>
    <#if section = "header">
        ${msg("loginAccountTitle")}
    <#elseif section = "info" >
        <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
            <div id="kc-registration-container">
                <div id="kc-registration">
                    <span>${msg("noAccount")}</span>
                    &nbsp;
                    <a class="bx--link" href="${url.registrationUrl}">${msg("doRegister")}</a>
                </div>
            </div>
        </#if>
    <#elseif section = "form">
        <div id="kc-form">
            <div id="kc-form-wrapper">
                <#if realm.password>
                    <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                        <div class="${properties.kcFormGroupClass!} bx--text-input-wrapper">
                            <label for="username" class="${properties.kcLabelClass!}"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label> 
                            <#if usernameEditDisabled??>
                                <input id="username" class="${properties.kcInputClass!}" name="username" value="${(login.username!'')}" type="text" disabled />
                            <#else>
                                <div class="bx--input__field-outer-wrapper">
                                    <div class="bx--text-input__field-wrapper" data-invalid="<#if messagesPerField.existsError('username','password')>true</#if>">
                                        <#if messagesPerField.existsError('username','password')>
                                            <svg width="16" height="16" fill-rule="evenodd" class="bx--text-input__invalid-icon">
                                                <path d="M8,1C4.2,1,1,4.2,1,8s3.2,7,7,7s7-3.1,7-7S11.9,1,8,1z M7.5,4h1v5h-1C7.5,9,7.5,4,7.5,4z M8,12.2	c-0.4,0-0.8-0.4-0.8-0.8s0.3-0.8,0.8-0.8c0.4,0,0.8,0.4,0.8,0.8S8.4,12.2,8,12.2z"></path>
                                                <path d="M7.5,4h1v5h-1C7.5,9,7.5,4,7.5,4z M8,12.2c-0.4,0-0.8-0.4-0.8-0.8s0.3-0.8,0.8-0.8	c0.4,0,0.8,0.4,0.8,0.8S8.4,12.2,8,12.2z" data-icon-path="inner-path" opacity="0"></path>
                                            </svg>
                                        </#if>
                                        <input id="username" class="${properties.kcInputClass!} <#if messagesPerField.existsError('username','password')>bx--text-input--invalid</#if>" name="username" value="${(login.username!'')}"  type="text" autofocus autocomplete="off"
                                            aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                                            <#if messagesPerField.existsError('username','password')>data-invalid="true"</#if>
                                        />
                                    </div>

                                    <#if messagesPerField.existsError('username','password')>
                                        <div class="bx--form-requirement" id="username-error-msg">
                                            <p class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                                    ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                            </p>
                                        </div>
                                    </#if>
                                </div>
                            </#if>
                        </div>

                        <div class="${properties.kcFormGroupClass!} bx--text-input-wrapper">
                            <div class="input-label-row">
                                <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>
                                <div class="${properties.kcFormOptionsWrapperClass!}">
                                    <#if realm.resetPasswordAllowed>
                                        <span><a class="bx--link" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></span>
                                    </#if>
                                </div>
                            </div>
                            <div class="bx--text-input__field-wrapper" data-invalid="<#if messagesPerField.existsError('username','password')>true</#if>">
                                <#if messagesPerField.existsError('username','password')>
                                    <svg width="16" height="16" fill-rule="evenodd" xmlns="http://www.w3.org/2000/svg" class="bx--text-input__invalid-icon">
                                        <path d="M8,1C4.2,1,1,4.2,1,8s3.2,7,7,7s7-3.1,7-7S11.9,1,8,1z M7.5,4h1v5h-1C7.5,9,7.5,4,7.5,4z M8,12.2	c-0.4,0-0.8-0.4-0.8-0.8s0.3-0.8,0.8-0.8c0.4,0,0.8,0.4,0.8,0.8S8.4,12.2,8,12.2z"></path>
                                        <path d="M7.5,4h1v5h-1C7.5,9,7.5,4,7.5,4z M8,12.2c-0.4,0-0.8-0.4-0.8-0.8s0.3-0.8,0.8-0.8	c0.4,0,0.8,0.4,0.8,0.8S8.4,12.2,8,12.2z" data-icon-path="inner-path" opacity="0"></path>
                                    </svg>
                                </#if>
                                <input id="password" class="${properties.kcInputClass!}" name="password" type="password" autocomplete="off"
                                    aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                                    <#if messagesPerField.existsError('username','password')>data-invalid="true"</#if>
                                />
                            </div>
                        </div>

                        <div class="${properties.kcFormGroupClass!} ${properties.kcFormSettingClass!}">
                            <div id="kc-form-options">
                                <#if realm.rememberMe && !usernameEditDisabled??>
                                    <div class="bx--form-item bx--checkbox-wrapper">
                                        <#if login.rememberMe??>
                                            <input id="rememberMe" class="bx--checkbox" name="rememberMe" type="checkbox" checked>
                                        <#else>
                                            <input id="rememberMe" class="bx--checkbox" name="rememberMe" type="checkbox">
                                        </#if>
                                        <label for="rememberMe" class="bx--checkbox-label"><span class="bx--checkbox-label-text">${msg("rememberMe")}</span></label>
                                    </div>
                                </#if>
                            </div>
                        </div> 
                        <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                            <input type="hidden" id="id-hidden-input" name="credentialId" value="<#if auth.selectedCredential?has_content>${auth.selectedCredential}</#if>" />
                            <button class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" name="login" id="kc-login" type="submit">
                                ${msg("doLogIn")}
                                <svg width="16" height="16" fill="currentColor" fill-rule="evenodd" class="bx--btn__icon" viewBox="0 0 22 22">
                                    <path d="M11.95 5.997L7.86 2.092 9.233.639l6.763 6.356-6.763 6.366L7.86 11.91l4.092-3.912H-.003v-2h11.952z" fill-rule="nonzero" transform="translate(4,4)" />
                                </svg>
                            </button>
                        </div>
                    </form>
                </#if>
            </div>
            <div class="social-providers">
                <#if realm.password && social.providers??>
                    <div id="kc-social-providers" class="${properties.kcFormSocialAccountSectionClass!}">
                        <hr/>
                        <p class="bx--form__helper-text">${msg("identity-provider-login-label")}</p>

                        <ul class="${properties.kcFormSocialAccountListClass!} <#if social.providers?size gt 3>${properties.kcFormSocialAccountListGridClass!}</#if>">
                            <#list social.providers as p>
                                <a id="social-${p.alias}" class="${properties.kcFormSocialAccountListButtonClass!} <#if social.providers?size gt 3>${properties.kcFormSocialAccountGridItem!}</#if>"
                                        type="button" href="${p.loginUrl}">
                                    <#if p.iconClasses?has_content>
                                        <i class="${properties.kcCommonLogoIdP!} ${p.iconClasses!}" aria-hidden="true"></i>
                                        <span class="${properties.kcFormSocialAccountNameClass!} kc-social-icon-text">Log in with ${p.displayName!}</span>
                                    <#else>
                                        <span class="${properties.kcFormSocialAccountNameClass!}">Log in with ${p.displayName!}</span>
                                    </#if>
                                </a>
                            </#list>
                        </ul>
                    </div>
                </#if>
            </div>
        </div>
    </#if>
</@layout.registrationLayout>
