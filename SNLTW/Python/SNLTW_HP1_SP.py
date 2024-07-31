import os
#Danh sách barcode của sp
bar_arry=['1','2','3','4','5','6','7','8']
listSP=['Bánh snack cua','Bánh snack bí đỏ','Bàn chải đánh răng PS','Lưỡi lam','Nước C2','Nước 7up','Nước aqua','Sữa chua vinamilk']
#Danh sách số lượng của sp
listSL=[10,15,12,20,25,21,30,11]
barcode=''
soLuong=0
tenSP=''
#Biến tạm khi nhập chuỗi
ans=''
#Khởi tạo phím chức năng
luachon=-1
while (luachon!=0):
  os.system('cls')
  #Tạo menu chức năng
  sao='{:*<31}'.format('')
  menu='\n*{:^29}*'.format('Chức năng')
  print(sao,menu+'\n'+sao)
  print('*{:<29}*'.format(' 0. Thoát chương trình'))
  print('*{:<29}*'.format(' 1. Nhập hàng'))
  print('*{:<29}*'.format(' 2. Xuất hàng'))
  print('*{:<29}*'.format(' 3. Tìm kiếm SP'))
  print('*{:<29}*'.format(' 4. In danh sách hàng tồn'))
  print('*{:<29}*'.format(' 5. Kiểm kê hàng hóa'))
  print('*{:<29}*'.format(' 6. Hướng dẫn sử dụng'))
  print(sao)
  luachon=int(input('Hãy chọn chức năng: '))
  os.system('cls')
  #1. Nhập hàng
  if (luachon==1):
    barcode=input('Nhập bar code sp: ')
    for i in range(len(bar_arry)):
      if(barcode==bar_arry[i]):
        print('Sản phẩm đã tồn tại trong kho.')
        listSL[i]+=int(input('Nhập số lượng bạn đưa vào kho: '))
        print('Thông tin SP đã nhập:')
        print('{:<10}'.format('Barcode'),'{:<30}'.format('Tên SP'),'{:<10}'.format('Số Lượng'))
        print('{:<10}'.format(bar_arry[i]),'{:<30}'.format(listSP[i]),'{:<10}'.format(listSL[i]))
        print('Nhập kho thành công')
        break
    else:
      print('Barcode vừa nhập không có trong kho')
      ans=input('Bạn có muốn thêm sản phẩm mới không( yes/no ): ')
      if(ans=='yes'): 
        bar_arry.append(barcode)
        tenSP=input('Nhập tên SP mới: ')
        listSP.append(tenSP)
        soLuong=int(input('Nhập số lượng SP: '))
        print('Nhập kho thành công')
        break
  #2. Xuất hàng
  elif (luachon==2):
    barcode=input('Nhập barcode muốn xuất: ')
    for i in range(len(bar_arry)):
      if(barcode==bar_arry[i]):
        print('Tên sản phẩm xuất kho là: ',listSP[i])
        soLuong=int(input('Nhập số lượng cần xuất: '))
        if(soLuong>listSL[i]):
          print('Số lượng vượt quá tồn kho')
          break
        listSL[i]-=soLuong
        print('Xuất kho thành công')
        break
    else:
      print('Barcode vừa nhập không tồn tại trong hệ thống')
  #3. Tìm sản phẩm
  elif (luachon==3):
    ans=input('Nhập Barcode hoặc tên SP cần tìm: ')
    for i in range(len(bar_arry)):
      if(ans==bar_arry[i] or (ans in listSP[i])==True):
        print('\tThông tin SP:')
        print('{:<10}'.format('Barcode'),'{:<30}'.format('Tên SP'),'{:<10}'.format('Số Lượng'))
        print('{:<10}'.format(bar_arry[i]),'{:<30}'.format(listSP[i]),'{:<10}'.format(listSL[i]))
    else:
      print('Không tìm thấy sản phẩm')
  #4. In danh sách hàng tồn
  elif (luachon==4):
    print('\t\tDanh sách hàng tồn kho\n')
    print('{:<10}'.format('Barcode'),'{:<30}'.format('Tên SP'),'{:<10}'.format('Số Lượng'))
    for i in range(len(bar_arry)):
      if(listSL[i]==0):
        print('{:<10}'.format(bar_arry[i]),'{:<30}'.format(listSP[i]),'Hết hàng')
      else:
        print('{:<10}'.format(bar_arry[i]),'{:<30}'.format(listSP[i]),'{:<10}'.format(listSL[i]))
  #5. Kiểm kê hàng hóa
  elif (luachon==5):
    barcode=input('Nhập barcode cần kiểm kho: ')
    for i in range(len(bar_arry)):
      if(barcode==bar_arry[i]):
        print('Tên SP: ',listSP[i],'\tSố lượng trên hệ thống: ',listSL[i])
        soLuong=int(input('Nhập số lượng thực kiểm kê được: '))
        if(soLuong<=listSL[i]):
          print('Số sản phẩm bị thất thoát: ',listSL[i]-soLuong)
        else:
          print('Bạn có chắc chắn đã kiểm đúng số lượng sp chưa. Vì số lượng thực tế lớn hơn trên hệ thống')
        ans=input('Bạn có muốn cập nhật số lượng kiểm được vào hệ thống không (yes/no): ')
        if(ans=='yes'):
          listSL[i]=soLuong
          print('Đã cập nhật thành công')
        else:
          print('Bạn đã từ chối cập nhật')
        break
    else:
      print('Barcode vừa nhập không có trong hệ thống. Hãy kiểm tra lại')
  #6. Hướng dẫn sử dụng
  elif (luachon==6):
    print('\t\tHƯỚNG DẪN SỬ DỤNG PHẦN MỀM')
    print("Để nhập hàng vào kho. Gõ phím '1' để chọn chức năng (1. Nhập hàng).\n\tSau đó hệ thống sẽ yêu cầu nhập Barcode sản phẩm.\n\tNếu sản phẩm đã có trong kho, thì nhập số lượng muốn thêm vào kho.\n\tNếu là sản phẩm mới yêu cầu điền thông tin của sản phẩm để thêm vào kho ")
    print("Để xuất hàng hóa ra kho. Gõ phím '2' để chọn chức năng (2. Xuất kho).\n\tSau đó hệ thống sẽ yêu cầu nhập Barcode sản phẩm.\n\tNếu barcode nhập vào chính xác. Hệ thống sẽ yêu cầu nhập số lượng cần xuất.Sau đó dữ liệu sẽ được cập nhật lại dựa trên sản phẩm đã xuất.\n\tLưu ý: Nếu số lượng cần xuất vượt quá số lượng tồn kho hoặc nhập sai barcode sản phẩm hệ thống sẽ báo lỗi. ")
    print("Để tìm kiếm hàng hóa trong kho. Gõ phím '3' để chọn chức năng (3. Tìm kiếm sản phẩm).\n\tSau đó hãy nhập tên hoặc barcode của sản phẩm để tìm kiếm")
    print("Để in ra danh sách hàng hóa trong kho. Gõ phím '4' để chọn chức năng (4. in danh sách hàng tồn)")
    print("Để kiểm kê, đếm lại số lượng hàng hóa trong kho và cập nhật lại dữ liệu. Gõ phím '5' để chọn chức năng (5.Kiểm kê hàng hóa)\n\tSau đó hãy nhập barcode sản phẩm cần kiểm kê. Hệ thống sẽ hiện thông tin sản phẩm trên hệ thông.\n\tVà nhập số lượng đã kiểm kê được. Nếu hao hụt hệ thống sẽ thông báo\n\tLưu ý: Nếu nhập sai barcode hệ thống sẽ báo lỗi hoặc nhập số lượng lớn hơn số lượng trong hệ thống hệ thống sẽ cảnh báo")
    print("Để thoát chương trình. Gõ phím '0'\n")
    print('{:*<100}'.format(''))
  #0. Thoát chương trình
  elif (luachon==0):
    print('Cảm ơn bản đã sử dụng chương trình')
    break
  else:
    print('Bạn đã nhập sai chức năng. Hãy nhập lại!')
  #Giúp cho chương trình dừng lại để người dùng quan sát
  a=input('\nNhâp phím bất kì để quay lại bảng chức năng: ')