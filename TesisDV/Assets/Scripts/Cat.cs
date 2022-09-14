using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class Cat : MonoBehaviour
{
    [SerializeField] private float _runninngSpeed;
    private bool _isHeld;
    private bool _isWalking;
    private bool _isRepositioning;
    [SerializeField] private Vector3 _startingPosition;
    [SerializeField] private GameObject _startingPositionGameObject;
    private NavMeshAgent _navMeshAgent;
    private LevelManager _lm;
    private Vector3 _exitPos;
    private Animator _animator;
    [SerializeField] private List<Vector3> _myPos = new List<Vector3>();
    void Awake()
    {
        _startingPositionGameObject = GameObject.Find("StartingPosition");
        _startingPosition = _startingPositionGameObject.transform.position;
        _isHeld = false;
        _navMeshAgent = GetComponent<NavMeshAgent>();
        _navMeshAgent.speed = 0.6f;
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _animator = GetComponent<Animator>();
        _animator.SetBool("IsIdle", true);
    }

    void Start()
    {
        SetStartingPosition();
    }

    void Update()
    {

        if(_isHeld == false && Vector3.Distance(transform.position, _startingPosition) > 3f)
        {
            
            Vector3 dest = default(Vector3);
            dest = _startingPosition;
            var dir = dest - transform.position;
            dir.y = 0f;
            /*Debug.Log("DISTANCE TO STARTING POS:" + Vector3.Distance(transform.position, _startingPosition));
            if(Vector3.Distance(transform.position, _startingPosition) < 3.025f)
            {
                _animator.SetBool("IsIdle", true);
            }*/
            _navMeshAgent.speed = _runninngSpeed;
            _navMeshAgent.destination = dest;
            //transform.rotation = Quaternion.Euler(0, transform.rotation.y, transform.rotation.z);
        }
        //else
        //{
        //    _navMeshAgent.destination = transform.position;
        //}
    }

    public void CatIsBeingTaken()
    {
        _isHeld = true;
        _isRepositioning = false;
        _animator.SetBool("IsMad", true);
        _navMeshAgent.enabled = false;
    }

    public void CatHasBeenReleased()
    {
        _isHeld = false;
        _isRepositioning = true;

        RepositionBetweenWaves();

        _animator.SetBool("IsIdle", false);
        _animator.SetBool("IsMad", false);
        _animator.SetBool("IsWalking", true);
        //_navMeshAgent.isStopped = false;
        _navMeshAgent.enabled = true;
    }

    public void RepositionBetweenWaves()
    {
        Vector3 newPos = _myPos[Random.Range(0, 3)];

        if (newPos != _startingPosition)
        {
            _startingPosition = newPos;
        }
        else
        {
            _startingPosition = _myPos[Random.Range(0, 3)];
        }

    }

    public void SetStartingPosition()
    {
        if(!_isHeld)
        {
            transform.position = _myPos[Random.Range(0, 3)];
            //transform.position = _myPos[1];
            _startingPositionGameObject.transform.position = transform.position;
            _startingPosition = _startingPositionGameObject.transform.position;
        }
    }

    public void SetExitPos(Vector3 exitPos)
    {
        _exitPos = exitPos;
    }

    public float GetDistance()
    {
        return Vector3.Distance(transform.position, _exitPos);
    }

    public bool GetCatHeld()
    {
        return _isHeld;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.name.Equals("StartingPosition"))
        {
            //Debug.Log("ENTRA EN TRIGGER??");
            _animator.SetBool("IsIdle", true);
        }
    }

}
