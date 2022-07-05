using UnityEngine;
using System;
using FSM;
using UnityEngine.AI;
public class FleeingState : MonoBaseState
{
    private Cat _cat;
    public float movingSpeed;
    private Vector3 _exitPos;
    private Vector3 _shipDistance;
    private NavMeshAgent _navMeshAgent;
    public Vector3[] _waypoints;
    private bool pathIsCreated;
    private MiniMap miniMap;
    private int _currentWaypoint = 0;
    private bool canCreatePath;

    void Awake()
    {
        _navMeshAgent = GetComponent<NavMeshAgent>();
    }
    void Start()
    {
        Vector3 aux = new Vector3(transform.position.x, 0f, transform.position.z);
        _exitPos = aux;
        _cat = GameVars.Values.Cat;
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
        _cat.transform.position = transform.position + new Vector3(0f, 1.8f - 0.35f, -0.87f);
    }

     public override IState ProcessInput()
    {
       return this;
    }

    private void CalculatePath()
    {
        _navMeshAgent.ResetPath();
        NavMeshPath path = new NavMeshPath();
        //_navMeshAgent.CalculatePath(targetPosition, path);
        if (NavMesh.CalculatePath(transform.position, _exitPos, NavMesh.AllAreas, path))
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
