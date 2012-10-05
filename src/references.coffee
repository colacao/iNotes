# Wraps an URL to a Dropbox file or folder that can be publicly shared.
class DropboxPublicUrl
  # Creates a PublicUrl instance from a raw API response.
  #
  # @param {?Object} urlData the parsed JSON describing a public URL
  # @param {Boolean} isDirect true if this link was obtained using the /media
  #     API
  # @return {?Dropbox.PublicUrl} a PublicUrl instance wrapping the given public
  #     link info; parameters that don't look like parsed JSON are returned as
  #     they are
  @parse: (urlData, isDirect) -> 
    if urlData and typeof urlData is 'object'
      new DropboxPublicUrl urlData, isDirect
    else
      urlData

  # @return {String} the public URL
  url: undefined

  # @return {Date} after this time, the URL is not usable
  expiresAt: undefined

  # @return {Boolean} true if this is a direct download URL, false for URLs to
  #     preview pages in the Dropbox web app; folders do not have direct link
  #
  isDirect: undefined

  # @return {Boolean} true if this is URL points to a file's preview page in
  #     Dropbox, false for direct links
  isPreview: undefined

  # Creates a PublicUrl instance from a raw API response.
  #
  # @private
  # This constructor is used by Dropbox.PublicUrl.parse, and should not be
  # called directly.
  #
  # @param {?Object} urlData the parsed JSON describing a public URL
  constructor: (urlData, isDirect) ->
    @url = urlData.url
    @expiresAt = new Date Date.parse(urlData.expires)
    
    if isDirect is true
      @isDirect = true
    else if isDirect is false
      @isDirect = false
    else
      @isDirect = Date.now() - @expiresAt <= 86400000  # 1 day
    @isPreview = !@isDirect


# Reference to a file that can be used to make a copy across users' Dropboxes.
class DropboxCopyReference
  # Creates a CopyReference instance from a raw reference or API response.
  #
  # @param {?Object, ?String} refData the parsed JSON descring a copy
  #     reference, or the reference string
  @parse: (refData) ->
    if refData and (typeof refData is 'object' or typeof refData is 'string')
      new DropboxCopyReference refData
    else
      refData

  # @return {String} the raw reference, for use with Dropbox APIs
  tag: undefined

  # @return {Date} deadline for using the reference in a copy operation
  expiresAt: undefined

  # Creates a CopyReference instance from a raw reference or API response.
  # 
  # @private
  # This constructor is used by Dropbox.CopyReference.parse, and should not be
  # called directly.
  #
  # @param {?Object, ?String} refData the parsed JSON descring a copy
  #     reference, or the reference string
  constructor: (refData) ->
    if typeof refData is 'object'
      @tag = refData.copy_ref
      @expiresAt = new Date Date.parse(refData.expires)
    else
      @tag = refData
      @expiresAt = new Date()

