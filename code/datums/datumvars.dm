#define VV_MSG_MARKED "<br><font size='1' color='red'><b>Marked Object</b></font>"
#define VV_MSG_EDITED "<br><font size='1' color='red'><b>Var Edited</b></font>"
#define VV_MSG_DELETED "<br><font size='1' color='red'><b>Deleted</b></font>"

#define VV_NORMAL_LIST_NO_EXPAND_THRESHOLD 50
#define VV_SPECIAL_LIST_NO_EXPAND_THRESHOLD 150

/datum/proc/CanProcCall(procname)
	return TRUE

/datum/proc/can_vv_get(var_name)
	return TRUE

/datum/proc/vv_edit_var(var_name, var_value) //called whenever a var is edited
	if(var_name == NAMEOF(src, vars) || var_name == NAMEOF(src, parent_type))
		return FALSE
	vars[var_name] = var_value
	datum_flags |= DF_VAR_EDITED
	return TRUE

/datum/proc/vv_get_var(var_name)
	switch(var_name)
		if ("vars")
			return debug_variable(var_name, list(), 0, src)
	return debug_variable(var_name, vars[var_name], 0, src)

//please call . = ..() first and append to the result, that way parent items are always at the top and child items are further down
//add separaters by doing . += "---"
/datum/proc/vv_get_dropdown()
	. = list()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION("proc_call", "Call Proc")
	VV_DROPDOWN_OPTION("mark_object", "Mark Object")
	VV_DROPDOWN_OPTION("delete", "Delete")
	VV_DROPDOWN_OPTION("expose", "Show VV To Player")

//This proc is only called if everything topic-wise is verified. The only verifications that should happen here is things like permission checks!
//href_list is a reference, modifying it in these procs WILL change the rest of the proc in topic.dm of admin/view_variables!
/datum/proc/vv_do_topic(list/href_list)
	if(!usr || !usr.holder)
		return			//This is VV, not to be called by anything else.
	IF_VV_OPTION(VV_HK_EXPOSE)
		if(!check_rights(R_ADMIN, FALSE))
			return
		var/value = vv_get_value(VV_CLIENT)
		if (value["class"] != VV_CLIENT)
			return
		var/client/C = value["value"]
		if (!C)
			return
		var/prompt = alert("Do you want to grant [C] access to view this VV window? (they will not be able to edit or change anysrc nor open nested vv windows unless they themselves are an admin)", "Confirm", "Yes", "No")
		if (prompt != "Yes" || !usr.client)
			return
		message_admins("[key_name_admin(usr)] Showed [key_name_admin(C)] a <a href='?_src_=vars;[HrefToken(TRUE)];datumrefresh=[REF(src)]'>VV window</a>")
		log_admin("Admin [key_name(usr)] Showed [key_name(C)] a VV window of a [src]")
		to_chat(C, "[usr.client.holder.fakekey ? "an Administrator" : "[usr.client.key]"] has granted you access to view a View Variables window")
		C.debug_variables(src)
	IF_VV_OPTION(VV_HK_DELETE)
		if(!check_rights(R_DEBUG))
			return
		usr.admin_delete(src)
		if (isturf(src))  // show the turf that took its place
			usr.debug_variables(src)
	IF_VV_OPTION(VV_HK_MARK)
		if(usr.holder.marked_datum)
			usr.vv_update_display(usr.holder.marked_datum, "marked", "")
		usr.holder.marked_datum = D
		usr.vv_update_display(D, "marked", VV_MSG_MARKED)
	IF_VV_OPTION(VV_HK_CALLPROC)
		usr.callproc_datum(T)

/datum/proc/get_view_variables_header()
	. = list()
	if("name" in vars)
		. += "<b>[name]</b><br>"
	. += "[type]"

/datum/proc/on_reagent_change(changetype)
	return
