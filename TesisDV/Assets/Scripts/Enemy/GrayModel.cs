using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class GrayModel : MonoBehaviour
{
    private List<IPlayerDamageObserver> _myObserversPlayerDamage = new List<IPlayerDamageObserver>();
    private List<IDoorGrayInteractObserver> _myObserversDoorGrayInteract = new List<IDoorGrayInteractObserver>();

    public StateMachine _fsm;

    IController _myController;

    public Player _player { get; private set; }

    private NavMeshAgent _navMeshAgent;
    private NavMeshPath _navMeshPath;

    [SerializeField]
    public Vector3[] _waypoints;
    private int _currentWaypoint = 0;
    private int _currentCorner = 0;

    public LevelManager _lm { get; private set; }
    [SerializeField]
    private LineRenderer lineRenderer;
    MiniMap miniMap;

    #region Events
    public event Action<float> onGetDmgHUD = delegate { };
    public event Action<bool> onGetDmg = delegate { };
    public event Action onDeath = delegate { };
    public event Action<bool> onWalk = delegate { };
    public event Action<bool> onJump = delegate { };
    #endregion Events

    private void Awake()
    {
        _fsm = new StateMachine();
        _fsm.AddState(EnemyStatesEnum.CatState, new CatState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.ChaseState, new ChaseState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.AttackPlayerState, new AttackPlayerState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.AttackTrapState, new AttackTrapState(_fsm, this));
        _fsm.AddState(EnemyStatesEnum.EscapeState, new EscapeState(_fsm, this));
        _fsm.ChangeState(EnemyStatesEnum.CatState);
    }

    private void Start()
    {
        _myController = new GrayController(this, GetComponent<GrayView>());

        _player = GameVars.Values.Player;

        _navMeshAgent = GetComponent<NavMeshAgent>();

        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        //_lm.AddGray(this);  //Cambiar a GrayModel
        miniMap = FindObjectOfType<MiniMap>();
        //miniMap.grays.Add(this); // Cambiar a GrayModel
        miniMap.AddLineRenderer(lineRenderer);
    }

    public void ResetPathAndSetObjective(Vector3 targetPosition)
    {
        _navMeshAgent.ResetPath();
        CalculatePath(targetPosition);   
    }

    private void CalculatePath(Vector3 targetPosition)
    {
        //_waypoints = new List<Vector3>();
        //_waypoints = null;


        _navMeshAgent.ResetPath();
        NavMeshPath path = new NavMeshPath();
        //_navMeshAgent.CalculatePath(targetPosition, path);
        if (NavMesh.CalculatePath(transform.position, targetPosition, NavMesh.AllAreas, path))
        {
            _navMeshAgent.SetPath(path);

            for (int i = 0; i > _navMeshAgent.path.corners.Length; i++)
            {
                _waypoints[i] = _navMeshAgent.path.corners[i];
            }
            //pathIsCreated = true;
            DrawLineRenderer(path.corners);
        }

        //NavMesh.CalculatePath(transform.position, targetPosition, NavMesh.AllAreas, _navMeshPath)
    }

    private void DrawLineRenderer(Vector3[] waypoints)
    {
        lineRenderer.positionCount = waypoints.Length;
        lineRenderer.SetPosition(0, waypoints[0]);

        for (int i = 1; i < waypoints.Length; i++)
        {
            Vector3 pointPosition = new Vector3(waypoints[i].x, waypoints[i].y, waypoints[i].z);
            lineRenderer.SetPosition(i, pointPosition);
        }
    }

}
