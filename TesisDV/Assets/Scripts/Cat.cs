using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class Cat : MonoBehaviour
{
    IController _myController;
    public float _runningSpeed;
    public float _walkingSpeed;
    [SerializeField] private bool _isHeld;
    public bool IsHeld { 
        get { return _isHeld; } 
        set { _isHeld = value; }
    }
    public Enemy MyOwner;
    private bool _isWalking;
    private bool _isRepositioning;
    public Vector3 StartingPosition;
    public List<UFOLineRenderer> Renderers = new List<UFOLineRenderer>();
    public NavMeshAgent _navMeshAgent;
    private LevelManager _lm;
    private WaveManager _wm;
    [SerializeField]
    private CatCaptured _catCapturedUI;
    private Vector3 _exitPos;
    private Animator _animator;
    [SerializeField] private List<Vector3> _myPos = new List<Vector3>();
    public List<Transform> Path = new List<Transform>();
    public List<Transform> PathToBasement = new List<Transform>();
    public List<Transform> PathToShed = new List<Transform>();
    public List<Transform> PathToKitchen = new List<Transform>();

    public StateMachine _fsm { get; private set; }

    public bool canMove;
    public bool IsGoingBack;
    public bool IsInShed;
    public bool IsInKitchen;

    #region Events

    public event Action onIdle = delegate { };
    public event Action onWalk = delegate { };
    public event Action onRun = delegate { };
    public event Action onTaken = delegate { };
    public event Action onMeowing = delegate { };
    public delegate void OnCatBasementStateDelegate();
    public event OnCatBasementStateDelegate OnCatBasementState;
    public delegate void OnCatLivingStateFinishedDelegate();
    public event OnCatLivingStateFinishedDelegate OnCatLivingStateFinished;
    public delegate void OnDoorInteractDelegate();
    public event OnDoorInteractDelegate OnDoorInteract;
    #endregion Events
    void Awake()
    {
        _fsm = new StateMachine();
        _myController = new CatController(this, GetComponent<CatView>());
        _isHeld = false;
        _navMeshAgent = GetComponent<NavMeshAgent>();
        _navMeshAgent.speed = 0.6f;
        PathToBasement = FindObjectsOfType<Transform>().Where(x => x.name.Equals("CatWaypointsToBasement")).First()
            .GetComponentsInChildren<Transform>().Skip(1).ToList();
        PathToShed = FindObjectsOfType<Transform>().Where(x => x.name.Equals("CatWaypointsToShed")).First()
            .GetComponentsInChildren<Transform>().Skip(1).ToList();
        PathToKitchen = FindObjectsOfType<Transform>().Where(x => x.name.Equals("CatWaypointsToKitchen")).First()
            .GetComponentsInChildren<Transform>().Skip(1).ToList();
        
        _navMeshAgent.enabled = false;
        Path = FindObjectsOfType<Transform>().Where(x => x.name.Equals("CatWaypoints")).First()
            .GetComponentsInChildren<Transform>().Skip(1).ToList();
        
        _wm = GameObject.Find("GameManagement").GetComponent<WaveManager>();
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _catCapturedUI = FindObjectOfType<CatCaptured>(true);
        _animator = GetComponent<Animator>();
        _animator.SetBool("IsIdle", true);
        IsGoingBack = false;
        _fsm.AddCatState(CatStatesEnum.IdleState, new IdleState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.RoomState, new RoomState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.WalkingState, new WalkingState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.TakenState, new TakenState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.RunningState, new RunningState(_fsm, this));
        StartCoroutine(AddPlayerBasedStates());
        _fsm.AddCatState(CatStatesEnum.ShedState, new ShedState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.KitchenState, new KitchenState(_fsm, this));
    }

    void Start()
    {
        _fsm.ChangeCatState(CatStatesEnum.RoomState);
        StartCoroutine(SetRenderersAwait());
    } 

    void Update()
    {
        _myController.OnUpdate();
    }
    IEnumerator AddPlayerBasedStates()
    {
        yield return new WaitUntil(() => GameVars.Values != null && GameVars.Values.Player != null);
        _fsm.AddCatState(CatStatesEnum.BasementState, new BasementState(_fsm, this, GameVars.Values.Player));
        _fsm.AddCatState(CatStatesEnum.LivingState, new LivingState(_fsm, this, GameVars.Values.Player));
    }
    IEnumerator SetRenderersAwait() 
    {
        yield return new WaitUntil(() =>  _wm.UFOLineRenderersList.Count > 0);
        Renderers = _wm.UFOLineRenderersList;
        SetStartingPosition();
        LoadLastPathPositions();
    }
    public void LoadLastPathPositions() 
    {
        _myPos.Clear();
        _myPos.Add(Path.Last().position);
        _myPos.Add(PathToShed.Last().position);
        _myPos.Add(PathToKitchen.Last().position);
        
    }
    public void GoingBackToLiving() 
    {
        Invoke(nameof(CatIsGoingBackToLiving),8f);
    }

    public void CatIsGoingBackToLiving()
    {
        _isHeld = false;
        _isRepositioning = true;

        _navMeshAgent.enabled = false;
        _fsm.ChangeCatState(CatStatesEnum.LivingState);
    }

    public void CallBasementStateStart() 
    {
        OnCatBasementState();
    }

    public void CallLivingStateFinished()
    {
        OnCatLivingStateFinished();
    }
    public void DoorInteract()
    {
        OnDoorInteract();
    }
    public void CatIsGoingToBasement() 
    {
        _isHeld = false;
        _isRepositioning = true;

        _navMeshAgent.enabled = false;
        _fsm.ChangeCatState(CatStatesEnum.BasementState);
    }
    public void CatIsGoingToShed()
    {
        _isHeld = false;
        _isRepositioning = true;
        IsInShed = true;
        StartingPosition = GetNewPos();
        _navMeshAgent.enabled = false;
        _fsm.ChangeCatState(CatStatesEnum.ShedState);
    }

    public void CatIsGoingToKitchen()
    {
        _isHeld = false;
        _isRepositioning = true;
        IsInShed = false;
        IsInKitchen = true;
        StartingPosition = GetNewPos();
        _navMeshAgent.enabled = false;
        _fsm.ChangeCatState(CatStatesEnum.KitchenState);
    }

    public void CatTaken(Vector3 exitPos, Enemy enemy) 
    {
        SetExitPos(exitPos);
        SetOwner(enemy);
        _catCapturedUI.CapturedCatChangeUI(true);
        CatIsBeingTaken();
    }

    public void CatIsBeingTaken()
    {
        _isHeld = true;
        _isRepositioning = false;
        if(_navMeshAgent != null)
            _navMeshAgent.enabled = false;
        
        _fsm.ChangeCatState(CatStatesEnum.TakenState);
    }

    public void CatHasBeenReleased()
    {
        _isHeld = false;
        _isRepositioning = true;
        _catCapturedUI.CapturedCatChangeUI(false);
        RepositionBetweenWaves();

        _navMeshAgent.enabled = true;
        _fsm.ChangeCatState(CatStatesEnum.RunningState);
    }

    public void RepositionBetweenWaves()
    {
        GetNewPosition();
    }

    public void GetMidValue() 
    {
        var mid = _myPos.Count / 2;
        Debug.Log("MID VALUE: " + mid);
        StartingPosition = _myPos.ElementAt(mid);
    }

    public void SetStartingPosition()
    {
        _myPos = _myPos.AsEnumerable().Reverse().ToList();
        if (!_isHeld)
        {
            GetNewPosition();
        }
    }
    public void GetNewPosition() 
    {
        if (IsInShed)
        {
            GetMidValue();
        }
        else if (IsInKitchen)
        {
            StartingPosition = _myPos.Last();
        }
        else
        {
            StartingPosition = _myPos.First();
        }
    }

    public Vector3 GetNewPos() 
    {
        if (IsInShed)
        {
            var mid = _myPos.Count / 2;
            Debug.Log("MID VALUE: " + mid);
            StartingPosition = _myPos.ElementAt(mid);
        }
        else if (IsInKitchen)
        {
            StartingPosition = _myPos.Last();
        }
        else
        {
            StartingPosition = _myPos.First();
        }
        return StartingPosition;
    }
    public void EnterIdleState()
    {
        onIdle();
    }

    public void EnterWalkingState()
    {
        onWalk();
    }

    public void EnterTakenState()
    {
        onTaken();
    }

    public void EnterRunningState()
    {
        onRun();
    }
    public void SetOwner(Enemy Owner)
    {
        MyOwner = Owner;
    }
    public void SetExitPos(Vector3 exitPos)
    {
        _exitPos = exitPos;
    }

    public float GetDistance()
    {
        return Vector3.Distance(transform.position, _exitPos);
    }

    public void CanMove()
    {
        canMove = true;
    }

    public void GetDoor(Door door)
    {
        OpenDoor(door);
    }

    private void OpenDoor(Door door)
    {
        door.Interact();
    }

    public Vector3 GetStartingPosition()
    {
        
        return StartingPosition;
    }

    /* private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.name.Equals("StartingPosition"))
        {
            //Debug.Log("ENTRA EN TRIGGER??");
            _animator.SetBool("IsIdle", true);
        }
    } */
}
