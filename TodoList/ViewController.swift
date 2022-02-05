//
//  ViewController.swift
//  TodoList
//
//  Created by limyunhwi on 2022/01/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    //weak로 하게 되면 왼쪽 내비게이션 바 버튼이 Done이 되었을 때 이 Edit 버튼이 메모리에서 해제가 되어버려서 재사용할 수 없게 된다.따라서 strong 아울렛 변수가 되도록 설정해야한다.
    var doneButton: UIBarButtonItem?
    
    var tasks: [Task] = [] {
        //프로퍼티 옵저버
        didSet{//tasks 배열에 할 일이 추가될 때마다 saveTasks가 호출되어 UserDefaults에 할 일이 저장된다.
            self.saveTasks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap)) //버튼 생성
        //원래 셀렉터는 오브젝트-C에서 맥클래스? 메서드를 가리키는데 사용했던 참조타입이다. 동적 호출 등의 목적으로 사용되었다.
        //이것이 스위프트로 넘어오면서 구조체 형식으로 정의가 되고 #selector()구문을 사용하여 해당타입의 값을 생성할 수 있게 되었다.
        self.tableView.dataSource = self //UITableViewDataSource 프로토콜 채택하기
        self.tableView.delegate = self //cell을 눌렀을 때 할 일을 완료했다는 체크마크가 뜨도록 만들기
        self.loadTasks() //앱을 실행할 때마다 저장된 할 일들을 불러온다
    }

    //Done버튼이 선택되었을 때
    //Selector타입으로 전달할 메서드를 작성할 때에는 @objc 버트리부트?를 필수로 작성해 주어야 한다.
    //이는 오브젝트-C와의 호환성을 위한 것으로,  스위프트에서 정의한 메서드를 오브젝트-C에서도 인식할 수 있게 만들어준다.
    //다시 Edit버튼이 되고 편집모드에서 빠져나오도록 구현
    @objc func doneButtonTap(){
        self.navigationItem.leftBarButtonItem = self.editButton //다시 EditButton이 되도록 한다
        self.tableView.setEditing(false, animated: true) //tableView가 편집모드에서 빠져나오도록 한다.
    }
    
    //edit버튼 클릭시 tableView가 편집모드로 전환될 수 있도록 구현
    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        guard !self.tasks.isEmpty else {return}//테이블뷰가 비어있으면 편집할 필요가 없음
        self.navigationItem.leftBarButtonItem = self.doneButton //Edit버튼 클릭 시 Done버튼으로 변경되도록 한다.
        self.tableView.setEditing(true, animated: true) //tableView를 편집모드로 전환
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
    
    /*
     UserDefaults
     런타임 환경에서 동작하면서 앱이 실행되는 동안 기본 저장소에 접근해 데이터를 기록하고 가져오는 역할을 하는 인터페이스
     Key-Value 쌍으로 저장되고 싱글턴 패턴으로 설계되어 앱 전체에 단 하나의 인스턴스만 존재하게 된다.
     UserDefaults는 여러가지 타입을 저장할 수 있는데, 스위프트 안에 있는 Float, Int, Double, Bool, Url 등 기본적으로 제공하는 타입과 NSData, NSString, NSNumber 등 NS 관련 타입도 저장이 가능하다.
     UserDefaults에 ‘할 일’을 저장하는 것을 구현해보자
     */
    //할 일이 추가될 때 마다 호출할 예정
    func saveTasks() {
        //배열에 있는 요소들을 딕셔너리 형태로 mapping(하나의 값을 다른 값으로 대응시키기)
        let data = self.tasks.map{
            [
                "title": $0.title, //key:value
                "done": $0.done  //key:value
            ]
        }
        let userDefaults = UserDefaults.standard //유저 디펄슨에 접근할 수 있도록 만들기
        //UserDefaults는 싱글턴이기 때문에 하나의 인스턴스만 존재한다.
        userDefaults.setValue(data, forKey: "tasks") //유저 디펄스에 데이터 저장하기 키와 값이 쌍으로 저장된다.
    }
    
    //앱을 재실행했을 때 저장된 할 일들을 load할 예정
    //UserDefaults에 저장된 할 일들을 가져오기
    func loadTasks() {
        let userDefaults = UserDefaults.standard // UserDefaults에 접근하기
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else {return}
        //object(forKey:) 메서드는 Any 타입을 반환하는데, 데이터를 딕셔너리 배열 타입으로 저장했으므로 딕셔너리 배열 형태로 타입 캐스팅을 한다.
        //타입 캐스팅에 실패하면 nil이 될 수도 있으므로 guard문 사용한다.
        //저장된 데이터 키값을 이용해 불러오기
        
        self.tasks = data.compactMap{ //compactMap은 nil인 아닌 결과만을 모아 배열로 반환
            guard let title = $0["title"] as? String else {return nil}
            guard let done = $0["done"] as? Bool else {return nil}
            return Task(title: title, done: done) ///Task타입이 되도록 인스턴스화한다.
        }
        //다시 tasks 배열에 저장하기 위해서 data를 tasks 타입의 배열이 되도록 mapping한다.
        //$0 축약인자로 딕셔너리에 접근을 하고, title 키로 value 가져오기. 딕셔너리의 value가 Any 타입이므로 String으로 형변환. 타입 변환 실패시 nil 반환
        //$0 축약인자로 딕셔너리에 접근을 하고, done 키로 value를 가져오기. 딕셔너리의 value가 Any 타입이므로 Bool로 형변환
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
        
        // done이 true이면 cell에 체크마트 그리기, 아니면 그리지 않기
        if task.done {
            cell.accessoryType = .checkmark
        } else{
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    //편집모드에서 삭제버튼을 눌렀을때 삭제 버튼이 눌러진 셀이 어떤 셀이 눌러졌는지 알려준다.
    //편집모드에 들어가지 않더라도 스와이프로 삭제할 수 있게 해준다.
    //스와이프 모드, 편집모드에서 버튼을 선택하면 호출되는 메서드
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row) //tasks배열에 삭제 버튼이 눌러진 행이 테이블뷰에서 사라지게 한다
        tableView.deleteRows(at: [indexPath], with: .automatic) //tableView에도 할 일이 삭제되게 처리한다.
        
        //만약 모든 할 일이 삭제된다면 Done버튼이 자동으로 호출되어 편집모드를 빠져나가게 한다.
        if self.tasks.isEmpty {
            self.doneButtonTap()
        }
    }
    
    //편집모드에서 셀 재정렬하기 위한 메서드 canMoveRowAt메서드와 moveRowAt메서드
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //행이 다른 위치로 이동되면 어디에서 어디로 이동했는지 알려주는 메서드
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //tableView가 재정렬된 순서대로 배열도 재정렬
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row] //배열의 요소에 접근하기
        tasks.remove(at: sourceIndexPath.row) //원래 위치에 있던 할 일을 삭제하기
        tasks.insert(task, at: destinationIndexPath.row) //이동한 위치에 할 일 집어넣기
        self.tasks = tasks //재정렬된 배열을 기존 배열에 대입하기
    }
}

//가독성을 위해 따로 UITableViewDelegate 프로토콜 채택
extension ViewController: UITableViewDelegate {
    //cell이 선택되었을 때 어떤 cell이 선택되었는지 알려주는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done //true라면 false가 되도록, false면 true가 되도록 한다.
        self.tasks[indexPath.row] = task //재설정한 값을 원래 값 위에 덮는다.
        self.tableView.reloadRows(at: [indexPath], with: .automatic) //선택된 cell만 reload하게 한다.
        //인덱스패치 구조체의 배열을 넘겨주는데, 즉 단일 행 뿐만이 아니라 여러 개의 cell을 reload하게 만들 수 있다는 의미
        //with 파라미터는 행이 업데이트 될 때 어느 애니메이션으로 작동할 지 지정하는 파라미터이다. 예 좌측 우측 으로 이동하며 사라지기
    }
}
