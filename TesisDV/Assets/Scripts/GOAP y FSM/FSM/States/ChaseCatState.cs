using UnityEngine;
using FSM;
using System.Collections;
using System.Linq;

public class ChaseCatState : MonoBaseState
{
    private PathfindingManager _pfManager;
    private Cat _cat;
    private Vector3 _exitPos;
    public float movingSpeed;
    private float _catDistance;
    private float _takeCatDistance = 6f;
    private float _engageThreshold = 5f;
    private bool _isPlayerInSight = false;
    private bool pathIsCreated;
    private MiniMap miniMap;
    private int _currentWaypoint = 0;
    private bool canCreatePath;
    private EnemyHealth _myHealth;

    private Node StartingPoint;
    private Node EndingPoint;
    public Node[] myPath;
    private AStar<Node> _aStar;

    void Awake()
    {
        _myHealth = GetComponent<EnemyHealth>();
    }

    void Start()
    {
        _pfManager = GameObject.Find("PathfindingManager").GetComponent<PathfindingManager>();
        _cat = GameVars.Values.Cat;
        Vector3 aux = new Vector3(transform.position.x, 0f, transform.position.z);
        _exitPos = aux;
        miniMap = FindObjectOfType<MiniMap>();

        StartingPoint = _pfManager.GetClosestNode(transform.position);
        EndingPoint = _pfManager.GetClosestNode(_cat.transform.position);
        canCreatePath = true;
        _aStar = new AStar<Node>();
        StartCoroutine(FindPath());
        canCreatePath = false;
    }

    private IEnumerator FindPath()
    {
        _aStar.OnPathCompleted += path =>
        {
            myPath = path.ToList().ToArray();
            pathIsCreated = true;
        };

        _aStar.OnCantCalculate += () =>
        {
            Debug.Log("No path found");
        };

        yield return _aStar.Run(
            StartingPoint,
            node => { return node == EndingPoint; },
            node =>
            {
                var neighbours = node.GetNeighbours();
                return neighbours;
            },
            node =>
            {
                float heuristic = node.GetHeuristic(EndingPoint);
                return heuristic;
            }
        );
    }

    public override void UpdateLoop()
    {
        _catDistance = Vector3.Distance(_cat.transform.position, transform.position);

        Move();

        if (_catDistance < _takeCatDistance && !_myHealth._hasCat)
        {
            _cat.transform.position = transform.position + new Vector3(0f, 1.8f - 0.35f, -0.87f);
            GameVars.Values.TakeCat(_exitPos);
            _myHealth._hasCat = true;
        }
    }

    public override IState ProcessInput()
    {
        if (_myHealth._hasCat)
        {
            return Transitions["OnFleeingState"];
        }

        return this;
    }

    private void Move()
    {
        if (pathIsCreated)
        {
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
