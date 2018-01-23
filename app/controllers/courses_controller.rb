class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list]
  before_action :teacher_logged_in, only: [:new, :create,  :destroy]
  #before_action :admin_logged_in, only: [:new, :create, :edit, :destroy, :update]
  before_action :logged_in, only: :index

  #-------------------------for teachers------------------
  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    @course.course_state = "processing_open"

    #-----------------规范化数据输入-------------------------
    @course.class_room = "J"+@course.class_room[1,@course.class_room.length-1]  #规范化教室数据
    @course.course_week = @course.course_week[1,@course.course_week.length-2]   #规范化上课周数数据

    case @course.course_time[1]
      when "一" then
        @course.course_time[1] = "1"
      when "二" then
        @course.course_time[1] = "2"
      when "三" then
        @course.course_time[1] = "3"
      when "四" then
        @course.course_time[1] = "4"
      when "五" then
        @course.course_time[1] = "5"
      when "六" then
        @course.course_time[1] = "6"
      when "日" then
        @course.course_time[1] = "7"
      else
        @course.course_time[1] = "1"
    end

    course_time = @course.course_time[1,@course.course_time.length-3]
    course_time = course_time[0]+"-"+course_time[2..course_time.length-1]
    @course.course_time = course_time   #规范化上课时间数据

    #render plain: @course.course_time.inspect
    #-----------------规范化数据输入-------------------------

    if @course.save
      current_user.teaching_courses<<@course

      @course.update_attribute("course_state", "待审核")
      redirect_to courses_path, flash: {success: "新课程申请成功"}

    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end

  end

  def edit
    @course=Course.find_by_id(params[:id])
    courses = Course.all

    #-----------------规范化数据输出---------------------
    #规范化教室数据
    @course.class_room[0] = "教"
    #规范化上课周数数据
    @course.course_week = "第"+@course.course_week+"周"
    #规范化上课时间数据
    case @course.course_time[0]
      when "1" then
        @course.course_time[0] = "一"
      when "2" then
        @course.course_time[0] = "二"
      when "3" then
        @course.course_time[0] = "三"
      when "4" then
        @course.course_time[0] = "四"
      when "5" then
        @course.course_time[0] = "五"
      when "6" then
        @course.course_time[0] = "六"
      when "7" then
        @course.course_time[0] = "日"
      else
        @course.course_time[0] = "一"
    end
    @course.course_time[1] = "（"
    @course.course_time = "周"+@course.course_time+"）节"

    #render plain: @course.course_time.inspect
    #-----------------规范化数据输出---------------------

    flag_code_confilct = false
    while flag_code_confilct==false
      time = Time.now.to_i.to_s[-4,4]
      @code = "091M"
      @code = @code + time + "H"
      courseAll = Course.find_by_sql("Select count(*) from courses where course_code = '#{@code}'")
      if courseAll != 0
        flag_code_confilct= true
      end
    end
  end

  def update
    @course = Course.find_by_id(params[:id])

    #render plain: @course.course_code.inspect

    if admin_logged_in? && @course.update_attribute("course_code",course_params[:course_code])
      @course.update_attribute("course_state", "已通过")
      flash={:info => "已成功开通此课程"}


   elsif @course.update_attributes(course_params)
        @course.update_attribute("course_state", "待审核")
        flash={:info => "更新成功"}

    else

        flash={:warning => "更新失败"}
    end

    redirect_to courses_path, flash: flash
  end


  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def open
    @course = Course.find_by_id(params[:id])
    #@course.update_attribute("open", true)
    @course.update_attribute("course_state","processing_open")
    redirect_to courses_path, flash: {:success => "已成功将该开课申请提交到管理员处理"}
  end

  def close
    @course = Course.find_by_id(params[:id])
    @course.update_attribute("course_state","processing_close")
    redirect_to courses_path, flash: {:success => "已成功将该关课申请提交到管理员处理"}
  end

  def agree
    @course = Course.find_by_id(params[:id])
    @course.update_attribute("course_state", '已通过')
    redirect_to courses_path, flash: {:success => "已同意开设此课程"}
  end

  def disagree
    @course = Course.find_by_id(params[:id])
    @course.update_attribute("course_state", '已驳回')
    redirect_to courses_path, flash: {:success => "已驳回此课程申请"}
  end



  #-------------------------for students----------------------



  def list

    #@course = Course.paginate(:page=>params[:page],:per_page=>8)
    @course = Course.all
    @course=@course - current_user.courses
    @course_open = Array.new # 定义数组类变量, []
    @course.each do |course| # 循环数组

      if(course.open == true && course.course_state == "已通过")
        if !course.limit_num
          course.update_attribute('limit_num',400)
        end
        @course_open<< course #追加，写进数组
      end
    end


    @course = @course_open


    #------------分页---------------------
    total = @course.count
    params[:total] = total
    if params[:page] == nil
      params[:page] = 1  #进行初始化
    end
    if total % $PageSize == 0
      params[:pageNum] = total / $PageSize
    else
      params[:pageNum] = total / $PageSize + 1
    end

    #计算分页的开始和结束位置
    params[:pageStart] = (params[:page].to_i - 1) * $PageSize
    if params[:pageStart].to_i + $PageSize <= params[:total].to_i
      params[:pageEnd] = params[:pageStart].to_i + $PageSize - 1
    else
      params[:pageEnd] = params[:total].to_i - 1  #最后一页
    end
    #---------------------------------------------------------------------
  end

  def courseinfo
    @course = Course.find_by_id(params[:id])

    #-----------------规范化数据输出---------------------
    #规范化教室数据
    @course.class_room[0] = "教"
    #规范化上课周数数据
    @course.course_week = "第"+@course.course_week+"周"
    #规范化上课时间数据
    case @course.course_time[0]
      when "1" then
        @course.course_time[0] = "一"
      when "2" then
        @course.course_time[0] = "二"
      when "3" then
        @course.course_time[0] = "三"
      when "4" then
        @course.course_time[0] = "四"
      when "5" then
        @course.course_time[0] = "五"
      when "6" then
        @course.course_time[0] = "六"
      when "7" then
        @course.course_time[0] = "日"
      else
        @course.course_time[0] = "一"
    end
    @course.course_time[1] = "（"
    @course.course_time = "周"+@course.course_time+"）节"

    #render plain: @course.course_time.inspect
    #-----------------规范化数据输出---------------------

  end

  #学生选课
  #学生选课
  def select
    @course=Course.find_by_id(params[:id])#查找
    course_weeks_new = @course.course_week.split("-")
    start_week_new = course_weeks_new[0].to_i
    end_week_new = course_weeks_new[1].to_i
    conflict_course_flag = false
    course_time_new = @course.course_week.split("-")  #周几-几-几-几节课

    current_user.courses.each do |course|
      course_weeks = course.course_week.split("-")
      start_week = course_weeks[0].to_i
      end_week = course_weeks[1].to_i
      course_time = course.course_week.split("-")  #周几-几-几-几节课

      for i in 1..course_time_new.length
        for j in 1..course_time.length
          if (course_time_new[0]==course_time[0] && course_time_new[i]==course_time[j])
            if(!((start_week > end_week_new) || (end_week < start_week_new)))
              conflict_course_flag =true
            end
          end
        end
      end
    end

    #student_num < @course.limit_num
    if(!conflict_course_flag)
      student_num = @course.student_num
      if student_num < @course.limit_num
        current_user.courses<<@course
        student_num = @course.student_num + 1
        if @course.update_attribute("student_num",student_num)
          flash={:success => "成功选择课程: #{@course.name}"}
        else
          flash={:success => "失败选择课程: #{@course.name}"}
        end
      end
    else
      flash={:success => "冲突选择课程: #{@course.name}"}
    end

    redirect_to courses_path, flash: flash
  end




  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)

    student_num = @course.student_num - 1
    if student_num < 0
      student_num=0
    end

    if @course.update_attribute("student_num",student_num)
      flash={:success => "成功退选课程: #{@course.name}"}
    else
      flash={:success => "退选课程: #{@course.name}失败"}
    end
    redirect_to courses_path, flash: flash #跳到下一个页面
  end


  def search
    #获取想要查询的字符串
    @course_search = params["course_search"]
    @search_type = params["search_type"]

    #生成数据表字段名

=begin
    if @search_type == "课程名称"
        search_colum = "name"
      elsif @search_type == "课程编号"
        search_colum = "course_code"
      elsif @search_type == "课程类型"
        search_colum = "course_type"
      elsif @search_type == "课程学分"
        search_colum = "credit"
      elsif @search_type == "上课周数"
        search_colum = "course_week"
      elsif @search_type == "上课时间"
        search_colum = "course_time"
      elsif @search_type == "考试类型"
        search_colum = "exam_type"
      else
        search_colum = "name"
    end
=end

    case @search_type
      when "课程名称" then
        search_colum = "name"
      when "课程编号" then
        search_colum = "course_code"
      when "课程类型" then
        search_colum = "course_type"
      when "课程学分" then
        search_colum = "credit"
      else
        search_colum = "name"
    end

    #防止sql注入，生成sql语句
    sql = "%"+@course_search+"%" #% ：表示任意0个或多个字符。可匹配任意类型和长度的字符
                              #有些情况下若是中文，请使用两个百分号（%%）表示

    @course = Course.find_by_sql("select * from courses where #{search_colum} like '#{sql}'")

  end



  def show
    @course=Course.find_by_id(params[:id])
  end



  #-------------------------for both teachers and students----------------------

  def index


    @course=Course.where("course_state='待审核'") if admin_logged_in?

    if teacher_logged_in?
    @course=current_user.teaching_courses.paginate(:page=>params[:page],:per_page=>5)

    end
    if student_logged_in?
    @course=current_user.courses.paginate(:page=>params[:page],:per_page=>5)
    @courses = current_user.courses
    @sum_time = 0
    @sum_credit = 0
    @courses.each do |courses|
     @sum_credit += courses.credit.split("/")[1].to_i
      @sum_time += courses.credit.split("/")[0].to_i
    end
    end
  end

  def create_course_code
    @course = Course.find_by_id(params[:id])
  end

  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week,
                                   :course_purpose, :pre_course, :textbook, :course_info, :teacher_info)
  end

  def course_params_new
    course_code = params[:course_code]
    params.require(:course).permit(course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week,
                                   :course_purpose, :pre_course, :textbook, :course_info, :teacher_info)
  end

  end
