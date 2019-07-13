var albumBucketName = 'jess-photo-albums';
var bucketRegion = 'eu-west-1';
var identityPoolId = 'eu-west-1:fd58c1e2-d075-4746-bfb7-9c03eb86ccd5';


AWS.config.update({
  credentials: new AWS.CognitoIdentityCredentials({IdentityPoolId: identityPoolId,}),
  region: bucketRegion
});
AWS.config.credentials.get(function (err) {
  if (err) 
    console.log(err);
});

var s3 = new AWS.S3({
  apiVersion: '2006-03-01',
  params: {Bucket: albumBucketName}
});

function listAlbums() {
    s3.listObjects({Delimiter: '/', Prefix: 'albums/'}, function(err, data) {
      if (err) {
        return alert('There was an error listing your albums: ' + err.message);
      } else {
        var albums = data.CommonPrefixes.map(function(commonPrefix) {
          var prefix = commonPrefix.Prefix;
          var albumNameSuffix = decodeURIComponent(prefix.replace('albums/', ''));
          var albumName = decodeURIComponent(albumNameSuffix.replace('/', ''));
          return getHtml([
              // '<a href="#" class="list-group-item" onclick="viewAlbum(\'' + albumName + '\')">',
              //   albumName,
              // '</a>',
              '<li class="nav-item">',
              '<a class="nav-link" onclick="viewAlbum(\'' + albumName + '\')" href="#' + albumName + '">' + albumName + '</a>',
              '</li>',
          ]);
        });
        var htmlTemplate = [
          '<a class="navbar-brand" href="#" onclick="(listAlbums()")>Albums</a>',
          '<ul class="navbar-nav">',
            getHtml(albums), 
          '</ul>',
        ]
        document.getElementById('albumNav').innerHTML = getHtml(htmlTemplate);
      }
    });
  }

async function createAlbum() {
// TODO not working due to async callback
  var isValidUser = await validUser();
  if (! isValidUser) {
    return;
  }

  var albumName = prompt("Enter Album Name","");
  albumName = "albums/" + albumName.trim();
  return;
  if (!albumName) {
    return alert('Album names must contain at least one non-space character.');
  }
  if (albumName.indexOf('/') !== -1) {
    return alert('Album names cannot contain slashes.');
  }
  var albumKey = encodeURIComponent(albumName) + '/';
  s3.headObject({Key: albumKey}, function(err, data) {
    if (!err) {
      return alert('Album already exists.');
    }
    if (err.code !== 'NotFound') {
      return alert('There was an error creating your album: ' + err.message);
    }
    s3.putObject({Key: albumKey}, function(err, data) {
      if (err) {
        return alert('There was an error creating your album: ' + err.message);
      }
      alert('Successfully created album.');
      viewAlbum(albumName);
    });
  });
}

function viewAlbum(albumName) {
  var albumPhotosKey = 'albums/' + albumName + '/';
  s3.listObjects({Prefix: albumPhotosKey}, function(err, data) {
    if (err) {
      return alert('There was an error viewing your album: ' + err.message);
    }
    // 'this' references the AWS.Response instance that represents the response
    var href = this.request.httpRequest.endpoint.href;
    var bucketUrl = href + albumBucketName + '/';

    var photos = data.Contents.map(function(photo) {
      var photoKey = photo.Key;
      // var photoUrl = bucketUrl + encodeURIComponent(photoKey);
      var photoUrl = bucketUrl + 'thumbnail/' + photoKey;
      // Ignore folder level objects
      if (! photoUrl.endsWith('/')) {
        return getHtml([
          '<div>',
            '<img id="photo-image" class="img-fluid img-rounded card-img-top"" src="' + photoUrl + '" onclick="displayModal(\'' + photoUrl + '\')"/>',  
            //'<img id="photo-image" class="img-fluid img-rounded card-img-top"" src="' + photoUrl + '"/>',  
          '</div>',
        ]);
      }
      
    });
    var message = photos.length ?
      '<p></p>' :
      '<p>You do not have any photos in this album. Please add photos.</p>';
    var htmlTemplate = [
      message,
      getHtml(photos),
    ]
    document.getElementById('photos').innerHTML = getHtml(htmlTemplate);
  });
}

function addPhoto(albumName) {
  var files = document.getElementById('photoupload').files;
  if (!files.length) {
    return alert('Please choose a file to upload first.');
  }
  var file = files[0];
  var fileName = file.name;
  var albumPhotosKey = encodeURIComponent(albumName) + '/';

  var photoKey = albumPhotosKey + fileName;
  s3.upload({
    Key: photoKey,
    Body: file,
    ACL: 'public-read'
  }, function(err, data) {
    if (err) {
      return alert('There was an error uploading your photo: ', err.message);
    }
    alert('Successfully uploaded photo.');
    viewAlbum(albumName);
  });
}

function deletePhoto(albumName, photoKey) {
  s3.deleteObject({Key: photoKey}, function(err, data) {
    if (err) {
      return alert('There was an error deleting your photo: ', err.message);
    }
    alert('Successfully deleted photo.');
    viewAlbum(albumName);
  });
}

function deleteAlbum(albumName) {
  var albumKey = encodeURIComponent(albumName) + '/';
  s3.listObjects({Prefix: albumKey}, function(err, data) {
    if (err) {
      return alert('There was an error deleting your album: ', err.message);
    }
    var objects = data.Contents.map(function(object) {
      return {Key: object.Key};
    });
    s3.deleteObjects({
      Delete: {Objects: objects, Quiet: true}
    }, function(err, data) {
      if (err) {
        return alert('There was an error deleting your album: ', err.message);
      }
      alert('Successfully deleted album.');
      listAlbums();
    });
  });
}

function displayModal(thumbnailUrl) {
  // Remove thumbnail/ string from url
  var fullSizeImage = thumbnailUrl.replace('thumbnail/','')
  console.log('new image --> ' + fullSizeImage)
  var modalImg = document.getElementById("fullImage");
  modalImg.src = fullSizeImage;
  openPhotoModal();
 
}

function openPhotoModal() {
  $(document).ready(function(){
     $("#fullPhoto").modal();
  });
}