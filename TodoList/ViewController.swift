//
//  ViewController.swift
//  TodoList
//
//  Created by limyunhwi on 2022/01/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.dataSource = self //UITableViewDataSource 프로토콜 채택하기
    }

    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in
            /*
             클로저 안에 tasks 배열에 할 일이 추가되도록 할 건데요,
             클로저 선언부에 캡쳐 목록을 정의해주겠습니다.
             대괄호 안에 week self를 작성해줄 건데요, [week self]
             클로저 선언부에서 캡쳐목록을 정의해주는 이유는
             클래스처럼 클로저는 참조타입이기 때문에
             클로저의 본문에서 self로 클래스의 인스턴스를 캡쳐할 때 강한 순환참조가 발생할 수 있는데요,
             여기서 강한 순환 참조란, AIC의 단점이기도 한데 두 개의 객체가 상호 참조하는 경우
             강한 순환 참조가 만들어지게 되는데, 이렇게 되면 강한 순환 참조에 연관된 객체들은
             레퍼런스 카운트가 0에 도달하지 않게되고 메모리 누수가 발생하게 된다.
             그렇다면 강한 순환참조를 해결하는 방법에는 뭐가 있을까요?
             클로저와 클래스의 인스턴스 사이의 강한 순환 참조를 해결하는 방법은
             클로저의 선언부에서 캡쳐 목록을 정의하는 것으로 해결할 수 있다.
             [weak self] <- 이게 바로 캡쳐 목록 정의한 것이다.
             클로저의 선언부에 weak나 unknowned? 키워드로 캡쳐 목록을 정의하지 않고
             클로저의 본문에서 self 키워드로 클래스의 인스턴스의 프로퍼티에 접근하게 되면 강한 순환 참조가 발생해
             메모리 누수가 있다는 점만 알아두고 자세한 건 추후 강의를 통해 공부하도록 하겠다.
             */
            //등록 버튼을 눌렀을 때, textField에 들어있는 값을 가져오자
            //debugPrint("\(alert.textFields?[0].text)") //콘솔창에 출력해보기
            //Alert에 한 개의 텍스트 필드만 설정했으므로 텍스트필드 배열인 textFields의 0번째에서 값 가져오기
            
            guard let title = alert.textFields?[0].text else{return}
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            //tasks에 할 일이 추가될 때마다 tableView가 갱신될 수 있도록 작성
            self?.tableView.reloadData()
        })
        let cancleButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(registerButton)
        alert.addAction(cancleButton)
        alert.addTextField(configurationHandler: {textField in
            textField.placeholder = "할 일을 입력해주세요." //미리보기
        })
        //configurationHandler는 Alert를 표시하기 전에 텍스트필드를 구성하기 위한 클로저
        //즉 Alert에 표시할 텍스트필드를 설정하는 클로저
        self.present(alert, animated: true, completion: nil)
        
    }
}

//가독성을 위해 따로 UITableViewDataSource 프로토콜 채택
extension ViewController: UITableViewDataSource {
    //각 섹션에 표시할 행의 개수 묻는 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    //특정 섹션의 n번째 로우를 그리는데 필요한 셀을 반환하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) //스토리보드에 정의한 셀을 가져오기. 이렇게 가져온 셀이 테이블 뷰에 표시되게 된다.
        //dequeueReusableCell : 재사용가능한 지정식별자(withIdentifier)의 재사용가능한 테이블 뷰의 셀을 반환하고 이를 테이블뷰에 추가하는 역할
        //indexPath 위치에 셀을 재사용하기 위해 받는다.
        //이 메서드를 사용하면 큐를 이용해 셀을 재사용하게 되는데, 큐를 이용해 셀을 재사용하는 이유는 메모리 낭비를 막기 위해서이다
        //일억 개의 셀이 필요하다고 일억 개를 만들면 메모리를 낭비하게 된다.
        //따라서 dequeueReusableCell 메서드를 사용해서 셀을 재사용하게 한다.
        //이렇게 스크롤을 내리면서 새로운 셀을 보게 되면, 기존의 셀 데이터 내용들은 리유브풀이라는 곳에 추가되어 들어가고
        //나중에 해당 데이터를 다시 보게 되면 dequeue를 통해서 풀에서 나오게 된다.
        
        //cell에 할 일 표시하기
        let task = self.tasks[indexPath.row] //indexPath.row의 개수는 0~tasks.count까지
        cell.textLabel?.text = task.title
        
        return cell
    }
}

