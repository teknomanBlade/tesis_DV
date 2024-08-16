using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using UnityEngine;
using UnityEngine.AI;

public class Cat : MonoBehaviour
{
    IController _myController;
    public float _runningSpeed;
    public float _walkingSpeed;
    private bool _isHeld;
    private bool _isWalking;
    private bool _isRepositioning;
    public Vector3 _startingPosition { get; private set; }
    //[SerializeField] private GameObject _startingPositionGameObject;
    public NavMeshAgent _navMeshAgent;
    private LevelManager _lm;
    private Vector3 _exitPos;
    private Animator _animator;
    [SerializeField] private List<Vector3> _myPos = new List<Vector3>();
    public List<Transform> Path = new List<Transform>();
    public List<Transform> PathToBasement = new List<Transform>();

    public StateMachine _fsm { get; private set; }

    public bool canMove;
    public bool IsGoingBack;

    #region Events

    public event Action onIdle = delegate { };
    public event Action onWalk = delegate { };
    public event Action onRun = delegate { };
    public event Action onTaken = delegate { };
    public event Action onMeowing = delegate { };

    #endregion Events
    void Awake()
    {
        _fsm = new StateMachine();
        _myController = new CatController(this, GetComponent<CatView>());
        _startingPosition = _myPos[2];
        _isHeld = false;
        _navMeshAgent = GetComponent<NavMeshAgent>();
        _navMeshAgent.speed = 0.6f;
        PathToBasement = FindObjectsOfType<Transform>().Where(x => x.name.Equals("CatWaypointsToBasement")).First()
            .GetComponentsInChildren<Transform>().Skip(1).ToList();
        _navMeshAgent.enabled = false;
        Path = FindObjectsOfType<Transform>().Where(x => x.name.Equals("CatWaypoints")).First()
            .GetComponentsInChildren<Transform>().Skip(1).ToList();
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _animator = GetComponent<Animator>();
        _animator.SetBool("IsIdle", true);
        IsGoingBack = false;
        _fsm.AddCatState(CatStatesEnum.IdleState, new IdleState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.RoomState, new RoomState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.WalkingState, new WalkingState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.TakenState, new TakenState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.RunningState, new RunningState(_fsm, this));
        _fsm.AddCatState(CatStatesEnum.BasementState, new BasementState(_fsm, this));
    }

    void Start()
    {
        SetStartingPosition();

        _fsm.ChangeCatState(CatStatesEnum.RoomState);
    }

    void Update()
    {
        _myController.OnUpdate();
    }

    public void CatIsGoingToBasement() 
    {
        _isHeld = false;
        _isRepositioning = true;

        _navMeshAgent.enabled = false;
        _fsm.ChangeCatState(CatStatesEnum.BasementState);
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

        RepositionBetweenWaves();

        _navMeshAgent.enabled = true;
        _fsm.ChangeCatState(CatStatesEnum.RunningState);
    }

    public void RepositionBetweenWaves()
    {
        //Vector3 newPos = _myPos[Random.Range(0, 3)];
        Vector3 newPos = _myPos[2];
        if (newPos != _startingPosition)
        {
            _startingPosition = newPos;
        }
        else
        {
            //_startingPosition = _myPos[Random.Range(0, 3)];
            _startingPosition = _myPos[2];
        }

    }

    public void SetStartingPosition()
    {
        if(!_isHeld)
        {
            //transform.position = _myPos[Random.Range(0, 3)];
            //transform.position = _myPos[2];
            //_startingPositionGameObject.transform.position = transform.position;
            _startingPosition = _myPos[2];
        }
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
        return _startingPosition;
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
