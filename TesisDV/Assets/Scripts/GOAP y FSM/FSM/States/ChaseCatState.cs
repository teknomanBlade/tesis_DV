using UnityEngine;
using System;
using FSM;
using System.Collections.Generic;
using UnityEngine.AI;
using System.Collections;
using System.Linq;

public class ChaseCatState : MonoBaseState
{
    [SerializeField] private PathfindingManager _pfManager;
    private Cat _cat;
    private Player _player;
    private Vector3 _exitPos;
    public float movingSpeed;
    private float _playerDistance;
    private float _catDistance;
    private float _takeCatDistance = 2.7f;
    private float _engageThreshold = 10f;
    private bool _hasCat = false;
    // private NavMeshAgent _navMeshAgent;
    // public Vector3[] _waypoints;
    private bool pathIsCreated;
    private MiniMap miniMap;
    private int _currentWaypoint = 0;
    private bool canCreatePath;
    private EnemyHealth _myHealth;

    public Node StartingPoint;
    public Node EndingPoint;
    public Node[] myPath;
    private AStar<Node> _aStar;

    void Awake()
    {
        _myHealth = GetComponent<EnemyHealth>();
        // _navMeshAgent = GetComponent<NavMeshAgent>();
        //_player = GameVars.Values.Player;
        //_cat = GameVars.Values.Cat;
    }

    void Start()
    {
        _player = GameVars.Values.Player;
        _cat = GameVars.Values.Cat;
        Vector3 aux = new Vector3(transform.position.x, 0f, transform.position.z);
        _exitPos = aux;
        miniMap = FindObjectOfType<MiniMap>();

        // StartingPoint = _pfManager.GetClosestNode(transform.position);
        // EndingPoint = _pfManager.GetClosestNode(_cat.transform.position);
        canCreatePath = true;
        _aStar = new AStar<Node>();
        StartCoroutine(FindPath());
        canCreatePath = false;
        pathIsCreated = true;
    }

    private IEnumerator FindPath()
{
    _aStar.OnPathCompleted += path => {
        myPath = path.ToList().ToArray();
        pathIsCreated = true;
        Debug.Log("Path found! FUCKING PATHISCREATED SHOULD BE TRUE");
    };

    _aStar.OnCantCalculate += () => {
        Debug.Log("No path found");
    };

    yield return _aStar.Run(
        StartingPoint,
        node => {
            Debug.Log($"Checking goal: {node.name}");
            return node == EndingPoint;
        },
        node => {
            var neighbours = node.GetNeighbours();
            Debug.Log(node.neighbours.Length);
            Debug.Log($"Neighbours for {node.name}: {string.Join(", ", neighbours.Select(n => n.Element.name))}");
            return neighbours;
        },
        node => {
            float heuristic = node.GetHeuristic(EndingPoint);
            Debug.Log($"Heuristic for {node.name} to {EndingPoint.name}: {heuristic}");
            return heuristic;
        }
    );
}


    public override void UpdateLoop()
    {
        /* foreach(KeyValuePair<string, FSM.IState> pair in Transitions)
        {
            Debug.Log(pair.Key);
            Debug.Log(pair.Value);
        } */


        _catDistance = Vector3.Distance(_cat.transform.position, transform.position);

        //         canCreatePath = true;
        //if (canCreatePath)
                //{
        //             // _navMeshAgent.ResetPath();
        //             // CalculatePath();
        //             //_currentCorner = 0;
                     //canCreatePath = false;
                     //pathIsCreated = false;
                 //}
        Move();

        if(_catDistance < _takeCatDistance && !_hasCat)
        {
            _cat.transform.position = transform.position + new Vector3(0f, 1.8f - 0.35f, -0.87f);
            GameVars.Values.TakeCat(_exitPos);
            _hasCat = true;
        }
    }

     public override IState ProcessInput()
    {

        if(_hasCat)
        {
            return Transitions["OnFleeingState"];
        }

        return this;
    }

    // private void CalculatePath()
    // {
    //     _navMeshAgent.ResetPath();
    //     NavMeshPath path = new NavMeshPath();
    //     //_navMeshAgent.CalculatePath(targetPosition, path);
    //     if (NavMesh.CalculatePath(transform.position, _cat.transform.position, NavMesh.AllAreas, path))
    //     {
    //         _navMeshAgent.SetPath(path);

    //         for (int i = 0; i > _navMeshAgent.path.corners.Length; i++)
    //         {
    //             _waypoints[i] = _navMeshAgent.path.corners[i];
    //         }
    //         pathIsCreated = true;
    //         _waypoints = path.corners;
    //         //miniMap.DrawWayPointInMiniMap();
    //     }
    // }

    private void Move()
    {
        Debug.Log(pathIsCreated);
        Debug.Log("Entre");
        if (pathIsCreated)
        {
            Debug.Log("Entre jajaja");
            Vector3 dir = myPath[_currentWaypoint].transform.position - transform.position;
            // Vector3 dir = _waypoints[_currentWaypoint] - transform.position;
            transform.forward = dir;
            transform.position += transform.forward * movingSpeed * Time.deltaTime;

            _myHealth.SetPosition(transform.position);

            if (dir.magnitude < 0.5f)
            {
                //_currentWaypoint++; Lo sumamos después de verificar.
                if (_currentWaypoint + 1 > myPath.Length) //-1
                // if (_currentWaypoint + 1 > _waypoints.Length) //-1
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
