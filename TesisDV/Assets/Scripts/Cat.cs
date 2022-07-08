using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class Cat : MonoBehaviour
{
    private bool _isHeld;
    private bool _isWalking;
    [SerializeField]
    private Vector3 _startingPosition;
    private GameObject _startingPositionGameObject;
    private NavMeshAgent _navMeshAgent;
    private LevelManager _lm;
    private Vector3 _exitPos;
    private Animator _animator;
    [SerializeField]
    private List<Vector3> _myPos = new List<Vector3>();
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
        SetPositionBetweenWaves();
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
        _animator.SetBool("IsMad", true);
        _navMeshAgent.enabled = false;
    }

    public void CatHasBeenReleased()
    {
        _isHeld = false;
        
        _animator.SetBool("IsIdle", false);
        _animator.SetBool("IsMad", false);
        _animator.SetBool("IsWalking", true);
        //_navMeshAgent.isStopped = false;
        _navMeshAgent.enabled = true;
    }

    public void SetPositionBetweenWaves()
    {
        if(!_isHeld)
        {
            transform.position = _myPos[Random.Range(0, 2)];
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
