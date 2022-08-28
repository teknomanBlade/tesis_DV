using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class GrayModel : MonoBehaviour
{
    private float _movingSpeed;
    private bool hasObjective;
    public StateMachine _fsm;

    IController _myController;

    public Player _player { get; private set; }
    public Cat _cat { get; private set; }

    private NavMeshAgent _navMeshAgent;
    private NavMeshPath _navMeshPath;

    public float pursueThreshold = 10f;
    public float disengageThreshold = 15f;
    public float attackThreshold = 2.5f;
    public float attackDisengageThreshold = 3f;

    [SerializeField]
    public Vector3[] _waypoints;
    private int _currentWaypoint = 0;
    private int _currentCorner = 0;

    public LevelManager _lm { get; private set; }
    [SerializeField]
    private LineRenderer lineRenderer;
    MiniMap miniMap;

    public Vector3 _exitPos;
    public Vector3 trapPos;

    [SerializeField] private Transform CatGrabPos;
    private Vector3 currentObjective;
    private BaseballLauncher currentObstacleTrap;
    public bool foundTrapInPath = false;

    #region Events
    public event Action<bool> onWalk = delegate { };
    public event Action onDeath = delegate { };
    public event Action onHit = delegate { };

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
        _cat = GameVars.Values.Cat;

        _navMeshAgent = GetComponent<NavMeshAgent>();

        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        //_lm.AddGray(this);  //Cambiar a GrayModel
        miniMap = FindObjectOfType<MiniMap>();
        //miniMap.grays.Add(this); // Cambiar a GrayModel
        miniMap.AddLineRenderer(lineRenderer);
    }

    public void SetObjective(Vector3 targetPosition)
    {
        currentObjective = targetPosition;
    }

    public void ResetPathAndSetObjective(Vector3 targetPosition)
    {
        _navMeshAgent.ResetPath();
        CalculatePath(targetPosition);   
    }

    private void CalculatePath(Vector3 targetPosition)
    {
        _navMeshAgent.ResetPath();
        NavMeshPath path = new NavMeshPath();
        if (NavMesh.CalculatePath(transform.position, targetPosition, NavMesh.AllAreas, path))
        {
            _navMeshAgent.SetPath(path);

            for (int i = 0; i > _navMeshAgent.path.corners.Length; i++)
            {
                _waypoints[i] = _navMeshAgent.path.corners[i];
            }
            DrawLineRenderer(path.corners);
        }
    }

    public void Move()
    {
        //if (pathIsCreated) Probar sin bool
        //{
            onWalk(true);
            Vector3 dir = _waypoints[_currentWaypoint] - transform.position;
            transform.forward = dir;
            transform.position += transform.forward * _movingSpeed * Time.deltaTime;

            if (dir.magnitude < 0.5f)
            {
                //_currentWaypoint++; Lo sumamos despu�s de verificar.
                if (_currentWaypoint + 1 > _waypoints.Length) //-1
                {
                    _currentWaypoint = 0;
                    //canCreatePath = true; probar con ResetAndSet directo.
                    ResetPathAndSetObjective(currentObjective);
                }
                else
                {
                    _currentWaypoint++;
                }

            }
        //}
    }

    public void GetDoor(Door door)
    {
        OpenDoor(door);
    }

    public void GrabCat()
    {
        //_anim.SetBool("IsGrab", true); Para el view
        GameVars.Values.TakeCat(_exitPos); //Ver que corno es esto
        hasObjective = true;
        _lm.CheckForObjective();
    }

    public void GoBackToShip()
    {
        if (hasObjective)
        {
            _lm.LoseGame();
            Destroy(_lm.objective);
        }
        //_lm.RemoveGray(this);
        //miniMap.RemoveGray(this);

        Destroy(gameObject);
    }
    
    public void TakeDamage()
    {

    }

    public void AttackPlayer()
    {
        //hacer animacion de AttackPlayer y que el collidertrigger haga el daño.
    }

    public void AttackTrap()
    {
        //hacer animación de EMPAttack y asignarle daño al trigger del EMPAttackGO.
    }

    public void FoundTrapInPath(GameObject trap)
    {
        trapPos = trap.transform.position;
        currentObstacleTrap = trap.GetComponent<BaseballLauncher>();
        foundTrapInPath = true;
    }

    private void OpenDoor(Door door)
    {
        door.Interact();

        //GameVars.Values.ShowNotification("The Grays have entered through the " + GetDoorAccessName(door.itemName));
        //TriggerDoorGrayInteract("GrayDoorInteract");
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

    public GrayModel SetExitUFO(Vector3 exitPosition)
    {
        Vector3 aux = exitPosition;
        _exitPos = new Vector3(aux.x, 0f, aux.z);

        return this;
    }
    

}
