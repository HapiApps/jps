const String domain="https://aci.hrides.in";
// const String domain="https://thirumald.hapirides.in";

const String path="ACI";
const String scriptFile="script.php";
const String taskFile="task_script.php";
const String imgFile="get_files.php";
const String leaveScriptFile="leave_script.php";
const String payrollScriptFile="payroll_script.php";
const String projectScriptFile="project_script.php";
const String phpFile="$domain/$path/$scriptFile";
const String taskScript="$domain/$path/$taskFile";
const String imageFile="$domain/$path/$imgFile";
const String leavePhpFile="$domain/$path/$leaveScriptFile";
const String payrollPhpFile="$domain/$path/$payrollScriptFile";
const String projectPhpFile="$domain/$path/$projectScriptFile";


const String loginUser="login";
const String logOut="log_out";
const String forgotPsd="forgot_password";

/// EMPLOYEE
const String signUp = "sign_up";
const String insertUsers = "insert_users";
const String updateUsers = "update_user";
const String createEmp = "create_employee";
const String updateEmp = "update_employee";
const String empActivity = "emp_activity";
const String addGrade = "add_grade";
const String empAttendance ="daily_attendance";
const String empPermission ="daily_permission";
const String insertExp ="insert_expense";
const String createExpense ="create_expense";
const String manageExpense ="manage_expense";
const String deleteAccount ="delete_account";
const String addGradeAmount ="add_grade_amount";

/// CUSTOMER
const String createCustomer ="create_customer";
const String updateCustomer ="update_customer";
const String custAttendance = "run_attendance";
const String addCmt ="insert_call_comments";
const String addVst ="insert_visit";
const String trackListInsert="track_list";
const String addTemplate="insert_templates";
const String updateTemplate="update_templates";
const String sendMail="send_mail";

const String getAllData = "get_data";
const String delete = "delete";

/// TRACK
const String trackingStatus="tracking_status";
const String insertTrack="insert_tracking";
const String getTrackDetails="get_track_details";

/// Task
const String adTask="create_task";
const String taskDatas="task_data";
const String taskAtt="task_attendance";
const String updateTask="update_task";
const String updateLevel="update_level";
const String addTaskType="add_task_type";
const String taskComments="task_comments";

/// Leave Management
const String fixLeave="fix_leave";
const String applyLeave="apply_leave";
const String listLeaves="list_of_leaves";
const String leaveType="leave_type";
const String addLeaveRules="add_leave_rules";
const String yearlyData="year_calender";
const String getLeaveData="get_leave_datas";

/// PAYROLL
const String payrollData="payroll_data";
const String insertPayrollDetails="insert_payroll_details";
const String addPayrollSalary="add_payroll_salary";
const String insertCategory="add_category";
const String insertPayrollSetting="insert_payroll_setting";
///
/// NOTIFICATION
const String roleNotification="role_notification";
const String userNotification="user_notification";
const String someUserNotification="some_user_notification";
const String adminNotification="admin_notification";


/// PROJECT
const String addProject="create_project";
const String editProject="edit_project";
const String removeProject="delete_project";
const String getProjectData = "project_data";
const String projectAtt="project_attendance";
const String prjGrpAtt="project_group_attendance";
const String insertWrkReport="insert_report";

/// ADD REPORT
const String addWrkReport="insert_work_report";
/// ADD PROJECT REPORT
const String addProjectReport="insert_project_report";
///
const String projectGroupAttendance="project_group_attendance";