using UnityEngine;
using System;
using FSM;
using UnityEngine.AI;

public class ChaseState : MonoBaseState
{
    private Player _player;
    public float movingSpeed;
    private float _playerDistance;
    private float _attackThreshold = 2.5f;
    private float _disengageThreshold = 10f;
    private NavMeshAgent _navMeshAgent;
    public Vector3[] _waypoints;
    private bool pathIsCreated;
    private MiniMap miniMap;
    private int _currentWaypoint = 0;
    private bool canCreatePath;
    private EnemyHealth _myHealth;

    void Awake()
    {
        _navMeshAgent = GetComponent<NavMeshAgent>();
        _myHealth = GetComponent<EnemyHealth>();
    }

    void Start()
    {
        _player = GameVars.Values.Player;
        miniMap = FindObjectOfType<MiniMap>();
    }

    public override void UpdateLoop()
    {
        canCreatePath = true;
        if (canCreatePath)
                {
                    _navMeshAgent.ResetPath();
                    CalculatePath();
                    //_currentCorner = 0;
                    canCreatePath = false;
                    pathIsCreated = false;
                }
        Move();
        //var dir = (_player.transform.position - transform.position).normalized;
        //transform.forward = dir;
        //transform.position += transform.forward * movingSpeed * Time.deltaTime;
    }

     public override IState ProcessInput()
    {
        _playerDistance = Vector3.Distance(_player.transform.position, transform.position);

        if(_playerDistance <= _attackThreshold)
        {
            return Transitions["OnAttackState"];
        }
        return this;
    }

    private void CalculatePath()
    {
        _navMeshAgent.ResetPath();
        NavMeshPath path = new NavMeshPath();
        //_navMeshAgent.CalculatePath(targetPosition, path);
        if (NavMesh.CalculatePath(transform.position, _player.transform.position, NavMesh.AllAreas, path))
        {
            _navMeshAgent.SetPath(path);

            for (int i = 0; i > _navMeshAgent.path.corners.Length; i++)
            {
                _waypoints[i] = _navMeshAgent.path.corners[i];
            }
            pathIsCreated = true;
            _waypoints = path.corners;
            miniMap.DrawWayPointInMiniMap();
        }
    }

    private void Move()
    {
        if (pathIsCreated)
        {
            Vector3 dir = _waypoints[_currentWaypoint] - transform.position;
            transform.forward = dir;
            transform.position += transform.forward * movingSpeed * Time.deltaTime;
            _myHealth.SetPosition(transform.position);

            if (dir.magnitude < 0.5f)
            {
                //_currentWaypoint++; Lo sumamos después de verificar.
                if (_currentWaypoint + 1 > _waypoints.Length) //-1
                {
                    _currentWaypoint = 0;
                    canCreatePath = true;
                }
                else
                {
                    _currentWaypoint++;
                }

            }
        }
    }
}
